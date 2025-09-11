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