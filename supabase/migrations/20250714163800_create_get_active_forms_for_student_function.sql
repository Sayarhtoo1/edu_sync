create or replace function get_active_forms_for_student(
    p_student_id int,
    p_class_ids int[],
    p_school_id int,
    p_date date
)
returns setof custom_forms as $$
begin
    return query
    select *
    from custom_forms
    where
        school_id = p_school_id and
        active_from <= p_date and
        active_to >= p_date and
        (
            assign_to_whole_school = true or
            assigned_student_ids @> array[p_student_id] or
            assigned_class_ids && p_class_ids
        );
end;
$$ language plpgsql;