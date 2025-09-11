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