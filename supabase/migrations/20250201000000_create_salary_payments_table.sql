-- Create salary_payments table
CREATE TABLE IF NOT EXISTS public.salary_payments (
  id UUID PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
  staff_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  school_id INTEGER NOT NULL REFERENCES public.schools(id) ON DELETE CASCADE,
  amount NUMERIC NOT NULL,
  payment_date DATE NOT NULL,
  payment_month VARCHAR(7) NOT NULL, -- Format: YYYY-MM
  payment_method VARCHAR(50) NOT NULL,
  transaction_id VARCHAR(255),
  status VARCHAR(20) NOT NULL CHECK (status IN ('Paid', 'Pending', 'Cancelled')),
  notes TEXT,
  paid_by UUID REFERENCES public.users(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for better query performance
CREATE INDEX idx_salary_payments_staff_id ON public.salary_payments(staff_id);
CREATE INDEX idx_salary_payments_school_id ON public.salary_payments(school_id);
CREATE INDEX idx_salary_payments_payment_month ON public.salary_payments(payment_month);
CREATE INDEX idx_salary_payments_status ON public.salary_payments(status);

-- Create a unique constraint to prevent duplicate payments for same staff in same month
CREATE UNIQUE INDEX idx_unique_staff_month_payment 
ON public.salary_payments(staff_id, payment_month) 
WHERE status = 'Paid';

-- Add comment
COMMENT ON TABLE public.salary_payments IS 'Tracks monthly salary payments to staff members';
