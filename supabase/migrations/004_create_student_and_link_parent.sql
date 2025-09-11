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