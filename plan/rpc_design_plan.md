# Supabase RPC Function Design Plan

This document outlines the design for converting critical multi-step database operations into atomic PostgreSQL functions (RPCs) to ensure data integrity within the EduSync application.

## 1. Identified Atomic Operations

The following client-side operations have been identified as requiring transactional integrity:

1.  **User Registration:** Creating a user in `auth.users` and a corresponding profile in `public.users`.
2.  **School Registration:** Creating a new school and assigning the administrator role to the creator.
3.  **Custom Form Submission:** Saving a form response and all its associated answers in a single transaction.
4.  **Student & Parent Creation:** Creating a new student and, if necessary, a new parent user account, and linking them.

---

## 2. SQL Function Designs

### 2.1. Auto-Create User Profile on Sign-Up (Trigger)

To handle the most common user creation case, a trigger will be used to automatically create a public user profile when a new user signs up via `auth.users`.

**SQL Definition:**

```sql
-- Function to create a public user profile
create function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.users (id, email, role, full_name, school_id)
  values (
    new.id,
    new.email,
    new.raw_user_meta_data->>'role',
    new.raw_user_meta_data->>'full_name',
    (new.raw_user_meta_data->>'school_id')::int
  );
  return new;
end;
$$;

-- Trigger to call the function after a new user is created
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
```

### 2.2. School Registration (`create_school_and_assign_admin`)

This function creates a new school and updates the user who created it to be the school's administrator.

**SQL Definition:**

```sql
create or replace function create_school_and_assign_admin(
    school_name text,
    admin_user_id uuid,
    logo_url text default null,
    academic_year text default null,
    theme text default null,
    contact_info text default null
)
returns int -- returns the new school's ID
language plpgsql
security definer set search_path = public
as $$
declare
    new_school_id int;
begin
    -- Start a transaction
    begin
        -- Insert the new school
        insert into public.schools (name, logo_url, academic_year, theme, contact_info)
        values (school_name, logo_url, academic_year, theme, contact_info)
        returning id into new_school_id;

        -- Update the user's role to 'Admin' and assign the school_id
        update public.users
        set school_id = new_school_id,
            role = 'Admin'
        where id = admin_user_id;

    exception
        when others then
            -- If any error occurs, roll back the transaction
            raise;
    end;
    
    return new_school_id;
end;
$$;
```

### 2.3. Custom Form Submission (`submit_form_with_answers`)

This function saves a form response and all its answers atomically. It accepts the answers as a JSONB array for flexibility.

**SQL Definition:**

```sql
create or replace function submit_form_with_answers(
    p_form_id uuid,
    p_student_id int,
    p_parent_id uuid,
    p_submitted_by_id uuid,
    p_answers jsonb -- e.g., '[{"field_id": "uuid", "answer_text": "..."}, ...]'
)
returns uuid -- returns the new form_response ID
language plpgsql
security definer set search_path = public
as $$
declare
    new_response_id uuid;
    answer_record jsonb;
begin
    -- Start a transaction
    begin
        -- 1. Insert the main form response
        insert into public.form_responses (form_id, student_id, parent_id, submitted_by)
        values (p_form_id, p_student_id, p_parent_id, p_submitted_by_id)
        returning id into new_response_id;

        -- 2. Loop through the JSON array of answers and insert them
        for answer_record in select * from jsonb_array_elements(p_answers)
        loop
            insert into public.form_response_answers (response_id, field_id, answer_text, answer_json)
            values (
                new_response_id,
                (answer_record->>'field_id')::uuid,
                answer_record->>'answer_text',
                answer_record->'answer_json' -- Assuming answer_json might be passed
            );
        end loop;

    exception
        when others then
            -- If any error occurs, roll back the transaction
            raise;
    end;

    return new_response_id;
end;
$$;
```

### 2.4. Create Student and Link Parent (`create_student_and_link_parent`)

This function creates a new student, optionally creates a new parent user, and links them in the `parent_student_relations` table.

**SQL Definition:**

```sql
create or replace function create_student_and_link_parent(
    p_student_name text,
    p_school_id int,
    p_class_id int,
    p_parent_id uuid, -- Can be an existing parent's UUID
    p_relation_type text,
    p_date_of_birth date default null,
    p_profile_photo_url text default null
)
returns int -- returns the new student's ID
language plpgsql
security definer set search_path = public
as $$
declare
    new_student_id int;
begin
    -- Start a transaction
    begin
        -- 1. Create the student
        insert into public.students (full_name, school_id, class_id, date_of_birth, profile_photo_url)
        values (p_student_name, p_school_id, p_class_id, p_date_of_birth, p_profile_photo_url)
        returning id into new_student_id;

        -- 2. Link the student to the parent
        -- This assumes the parent user (p_parent_id) already exists.
        -- If a new parent needs to be created, that should be done in a separate transaction
        -- or handled by a more complex RPC that also creates the auth user.
        -- For simplicity, this RPC assumes the parent exists.
        insert into public.parent_student_relations (parent_id, student_id, relation_type)
        values (p_parent_id, new_student_id, p_relation_type);

    exception
        when others then
            -- If any error occurs, roll back the transaction
            raise;
    end;

    return new_student_id;
end;
$$;
```

---

## 3. Client-Side Refactoring Plan

The following Dart files will need to be updated to call the new RPC functions instead of making multiple Supabase calls.

### 3.1. `lib/services/auth_service.dart`

*   **Change:** The `signUp` method can be simplified. The logic for creating a `public.users` entry is now handled by the `handle_new_user` trigger.
*   **Action:** No major change needed for `signUp`, but verify that the `user_meta_data` passed to `signUp` contains `role`, `full_name`, and `school_id`. The `createUserViaEdgeFunction` can be replaced by an RPC call if admin-level user creation is needed, or this can be handled by a more specific RPC.

### 3.2. `lib/services/school_service.dart`

*   **Change:** The `createSchool` method must be refactored.
*   **Action:** Replace the two separate `insert` and `update` calls with a single call to the `create_school_and_assign_admin` RPC.
    *   **Old Code:**
        ```dart
        // final response = await _supabaseClient.from('schools').insert({...}).select().single();
        // await _supabaseClient.from('users').update({'school_id': response['id']}).eq('id', adminUserId);
        ```
    *   **New Code:**
        ```dart
        // final newSchoolId = await _supabaseClient.rpc('create_school_and_assign_admin', params: {
        //   'school_name': name,
        //   'admin_user_id': adminUserId,
        //   // ... other params
        // });
        ```

### 3.3. `lib/services/form_response_service.dart`

*   **Change:** The `submitResponse` method must be refactored.
*   **Action:** Replace the multiple `insert` calls with a single call to the `submit_form_with_answers` RPC. The list of `FormResponseAnswer` objects will need to be serialized into a JSON array.
    *   **Old Code:**
        ```dart
        // final createdResponseData = await _supabaseClient.from('form_responses').insert(responseMap).select().single();
        // await _supabaseClient.from('form_response_answers').insert(answerMaps);
        ```
    *   **New Code:**
        ```dart
        // final List<Map<String, dynamic>> answersJson = answers.map((a) => a.toRpcJson()).toList();
        // final newResponseId = await _supabaseClient.rpc('submit_form_with_answers', params: {
        //   'p_form_id': response.formId,
        //   'p_student_id': response.studentId,
        //   'p_parent_id': response.parentId,
        //   'p_submitted_by_id': response.submittedBy,
        //   'p_answers': answersJson,
        // });
        ```

### 3.4. `lib/services/student_service.dart`

*   **Change:** The `createStudent` and `linkParentToStudent` methods will be replaced by a single RPC call in the UI layer.
*   **Action:** Create a new method, `createStudentWithParent`, that calls the `create_student_and_link_parent` RPC. The UI code in `add_edit_student_screen.dart` will need to be updated to call this new service method.
    *   **New Method in `student_service.dart`:**
        ```dart
        // Future<int?> createStudentWithParent(...) async {
        //   final newStudentId = await _supabaseClient.rpc('create_student_and_link_parent', params: { ... });
        //   return newStudentId;
        // }
        ```
    *   **UI Change in `lib/screens/admin/add_edit_student_screen.dart`:** The form submission logic will now call `studentService.createStudentWithParent(...)`.

---