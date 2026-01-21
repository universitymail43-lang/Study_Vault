-- Supabase SQL Schema for StudyNest
-- Includes RLS, UUIDs, and foreign keys for authentication.

-- 1. Enable UUID extension (if not already enabled)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. Create Categories Table
-- Stores custom categories for each user.
CREATE TABLE public.categories (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 3. Create Notes Table
-- Stores user notes linked to categories.
CREATE TABLE public.notes (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    category_id UUID REFERENCES public.categories(id) ON DELETE SET NULL, 
    title TEXT NOT NULL,
    content TEXT,
    is_pinned BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 4. Enable Row Level Security (RLS)
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notes ENABLE ROW LEVEL SECURITY;

-- 5. Helper Policy for Authenticated Users
-- Policies for Categories
CREATE POLICY "Users can view their own categories" 
ON public.categories FOR SELECT 
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own categories" 
ON public.categories FOR INSERT 
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own categories" 
ON public.categories FOR UPDATE 
USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own categories" 
ON public.categories FOR DELETE 
USING (auth.uid() = user_id);

-- Policies for Notes
CREATE POLICY "Users can view their own notes" 
ON public.notes FOR SELECT 
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own notes" 
ON public.notes FOR INSERT 
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own notes" 
ON public.notes FOR UPDATE 
USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own notes" 
ON public.notes FOR DELETE 
USING (auth.uid() = user_id);

-- 6. Indexes for Performance
CREATE INDEX idx_categories_user_id ON public.categories(user_id);
CREATE INDEX idx_notes_user_id ON public.notes(user_id);
CREATE INDEX idx_notes_category_id ON public.notes(category_id);

-- End of Schema
