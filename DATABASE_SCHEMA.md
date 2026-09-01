# Arete OS — Database Schema and Data Models

---

## 1. Database Architecture Overview

Arete utilizes **PostgreSQL 16** hosted on Supabase as the authoritative cloud persistence layer, integrated with **pgvector** for high-dimensional semantic search and strict **Row Level Security (RLS)** for multi-tenant isolation. 

For the web client, local persistence is mirrored into **IndexedDB / Hive** for zero-latency optimistic local updates with background bidirectional sync.

---

## 2. PostgreSQL Extensions and Custom Types

```sql
-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "vector";

-- Enums
CREATE TYPE goal_priority AS ENUM ('P0_CRITICAL', 'P1_STRATEGIC', 'P2_SUPPORTING');
CREATE TYPE goal_status AS ENUM ('DRAFT', 'ACTIVE', 'ACHIEVED', 'PAUSED', 'ABANDONED');
CREATE TYPE milestone_status AS ENUM ('PENDING', 'ACTIVE', 'BLOCKED', 'COMPLETED');
CREATE TYPE project_status AS ENUM ('BACKLOG', 'IN_PROGRESS', 'REVIEW', 'COMPLETED');
CREATE TYPE task_priority AS ENUM ('P0', 'P1', 'P2');
CREATE TYPE cognitive_tier AS ENUM ('DEEP_3X', 'MEDIUM_2X', 'SHALLOW_1X');
CREATE TYPE habit_frequency AS ENUM ('DAILY_MORNING', 'DAILY_EVENING', 'WEEKLY_TARGET', 'MONTHLY');
CREATE TYPE acoustic_preset AS ENUM ('BINAURAL_40HZ', 'BROWN_NOISE', 'OBSIDIAN_RAIN', 'TERMINAL_HUM', 'SILENT');
CREATE TYPE resource_type AS ENUM ('BOOK', 'COURSE', 'RESEARCH_PAPER', 'DOCUMENTATION', 'VIDEO');
```

---

## 3. Core Tables and Schema Definition

```sql
-- 1. Users Profile (Extends Supabase auth.users)
CREATE TABLE public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    full_name TEXT NOT NULL,
    current_energy_level INT DEFAULT 4 CHECK (current_energy_level BETWEEN 1 AND 5),
    timezone TEXT DEFAULT 'UTC',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Identities
CREATE TABLE public.identities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    vision_statement TEXT,
    color_token TEXT DEFAULT 'cosmic_violet',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Strategic Goals
CREATE TABLE public.goals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    identity_id UUID NOT NULL REFERENCES public.identities(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    objective_statement TEXT,
    target_deadline DATE NOT NULL,
    priority goal_priority DEFAULT 'P1_STRATEGIC',
    status goal_status DEFAULT 'ACTIVE',
    weighted_progress NUMERIC(5, 2) DEFAULT 0.00 CHECK (weighted_progress BETWEEN 0.00 AND 100.00),
    projected_completion_date DATE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Milestones
CREATE TABLE public.milestones (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    goal_id UUID NOT NULL REFERENCES public.goals(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    weight_multiplier NUMERIC(3, 2) DEFAULT 1.00 CHECK (weight_multiplier > 0),
    deadline DATE NOT NULL,
    status milestone_status DEFAULT 'PENDING',
    completion_percentage NUMERIC(5, 2) DEFAULT 0.00 CHECK (completion_percentage BETWEEN 0.00 AND 100.00),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Milestone Dependencies (DAG Relationships)
CREATE TABLE public.milestone_dependencies (
    milestone_id UUID NOT NULL REFERENCES public.milestones(id) ON DELETE CASCADE,
    prerequisite_milestone_id UUID NOT NULL REFERENCES public.milestones(id) ON DELETE CASCADE,
    PRIMARY KEY (milestone_id, prerequisite_milestone_id)
);

-- 6. Projects
CREATE TABLE public.projects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    milestone_id UUID NOT NULL REFERENCES public.milestones(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description_markdown TEXT,
    status project_status DEFAULT 'IN_PROGRESS',
    timeline_start DATE,
    timeline_end DATE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. Tasks
CREATE TABLE public.tasks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    project_id UUID NOT NULL REFERENCES public.projects(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    priority task_priority DEFAULT 'P1',
    cognitive_tier cognitive_tier DEFAULT 'MEDIUM_2X',
    estimated_minutes INT DEFAULT 45,
    actual_minutes_logged INT DEFAULT 0,
    is_completed BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMPTZ,
    postpone_count INT DEFAULT 0,
    recurrence_rrule TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 8. Subtasks
CREATE TABLE public.subtasks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    task_id UUID NOT NULL REFERENCES public.tasks(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    is_completed BOOLEAN DEFAULT FALSE,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 9. Habits
CREATE TABLE public.habits (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    milestone_id UUID REFERENCES public.milestones(id) ON DELETE SET NULL,
    title TEXT NOT NULL,
    frequency habit_frequency DEFAULT 'DAILY_MORNING',
    target_count_per_period INT DEFAULT 1,
    consistency_score NUMERIC(5, 2) DEFAULT 100.00,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 10. Habit Execution Logs
CREATE TABLE public.habit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    habit_id UUID NOT NULL REFERENCES public.habits(id) ON DELETE CASCADE,
    logged_date DATE NOT NULL,
    completed_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE (habit_id, logged_date)
);

-- 11. Focus Sessions (Deep Work Telemetry)
CREATE TABLE public.focus_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    task_id UUID REFERENCES public.tasks(id) ON DELETE SET NULL,
    duration_seconds INT NOT NULL,
    acoustic_preset acoustic_preset DEFAULT 'BINAURAL_40HZ',
    focus_quality_score NUMERIC(3, 1) DEFAULT 9.0,
    started_at TIMESTAMPTZ NOT NULL,
    ended_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 12. Time Blocks (Calendar Reservations)
CREATE TABLE public.time_blocks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    task_id UUID REFERENCES public.tasks(id) ON DELETE SET NULL,
    title TEXT NOT NULL,
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ NOT NULL,
    is_deep_work BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 13. Knowledge Notes (with Vector Embeddings)
CREATE TABLE public.knowledge_notes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    project_id UUID REFERENCES public.projects(id) ON DELETE SET NULL,
    title TEXT NOT NULL,
    content_markdown TEXT NOT NULL,
    embedding VECTOR(1536),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 14. Learning Resources
CREATE TABLE public.resources (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    project_id UUID REFERENCES public.projects(id) ON DELETE SET NULL,
    title TEXT NOT NULL,
    resource_type resource_type NOT NULL,
    url_or_filepath TEXT,
    total_units INT DEFAULT 100,
    completed_units INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 15. AI Retrospectives and Daily Plans
CREATE TABLE public.ai_retrospectives (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    review_date DATE NOT NULL,
    assessment_markdown TEXT NOT NULL,
    friction_diagnosis TEXT,
    recommended_schedule_json JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE (user_id, review_date)
);
```

---

## 4. Performance Indexes and Semantic Search

```sql
-- Standard Relational & User Isolation Indexes
CREATE INDEX idx_goals_user ON public.goals(user_id);
CREATE INDEX idx_milestones_goal ON public.milestones(goal_id);
CREATE INDEX idx_projects_milestone ON public.projects(milestone_id);
CREATE INDEX idx_tasks_project ON public.tasks(project_id);
CREATE INDEX idx_tasks_user_completed ON public.tasks(user_id, is_completed);
CREATE INDEX idx_habit_logs_date ON public.habit_logs(user_id, logged_date);
CREATE INDEX idx_focus_sessions_user_date ON public.focus_sessions(user_id, started_at);
CREATE INDEX idx_time_blocks_range ON public.time_blocks(user_id, start_time, end_time);

-- HNSW Vector Index for Semantic Note Retrieval
CREATE INDEX idx_knowledge_notes_embedding 
ON public.knowledge_notes 
USING hnsw (embedding vector_cosine_ops)
WITH (m = 16, ef_construction = 64);
```

---

## 5. Row Level Security (RLS) Policies

All tables enforce strict multi-tenant isolation so that users can only access their own data.

```sql
-- Enable RLS across all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.identities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.milestones ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.milestone_dependencies ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subtasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.habits ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.habit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.focus_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.time_blocks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.knowledge_notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.resources ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_retrospectives ENABLE ROW LEVEL SECURITY;

-- Standard Isolation Policies
CREATE POLICY "Users can view and edit their own profile" 
ON public.profiles FOR ALL USING (auth.uid() = id);

CREATE POLICY "Users access their own identities" 
ON public.identities FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users access their own goals" 
ON public.goals FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users access their own milestones" 
ON public.milestones FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users access their own projects" 
ON public.projects FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users access their own tasks" 
ON public.tasks FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users access their own habits" 
ON public.habits FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users access their own focus sessions" 
ON public.focus_sessions FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users access their own notes" 
ON public.knowledge_notes FOR ALL USING (auth.uid() = user_id);
```
