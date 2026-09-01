# Arete OS — API Specification and Edge Function Contracts

---

## 1. API Architecture Overview

Arete utilizes **Supabase PostgREST** for direct type-safe database access protected by Row Level Security (RLS), combined with **Deno-based Supabase Edge Functions** for AI processing, vector search, and batch mutation reconciliation.

All requests require standard Supabase authentication headers:
```http
Authorization: Bearer <JWT_TOKEN>
apikey: <SUPABASE_ANON_KEY>
Content-Type: application/json
```

---

## 2. Supabase Edge Functions

### 1. `POST /functions/v1/ai-deconstruct-goal`
Deconstructs a high-level goal into a structured Directed Acyclic Graph (DAG) of Milestones, Projects, Habits, and Initial Tasks.

#### Request Payload
```json
{
  "identity_title": "Senior Distributed AI Systems Architect",
  "goal_title": "Master GPU Architecture and Land Staff AI Role in 9 Months",
  "objective_statement": "Implement custom FlashAttention-2 Triton kernels and pass top-tier technical interviews.",
  "target_deadline": "2027-06-30",
  "weekly_hours_available": 20
}
```

#### Response Payload (200 OK)
```json
{
  "goal_id": "8f3b6c2a-9e12-4f81-b234-91283c74a123",
  "milestones": [
    {
      "title": "Master GPU Memory Hierarchy and Triton Kernel Optimization",
      "weight_multiplier": 3.0,
      "deadline": "2027-02-28",
      "projects": [
        {
          "title": "FlashAttention-2 Triton Implementation",
          "tasks": [
            { "title": "Implement tiled matrix multiplication in Triton", "cognitive_tier": "DEEP_3X", "estimated_minutes": 90 },
            { "title": "Profile SRAM shared memory bandwidth with Nsight", "cognitive_tier": "DEEP_3X", "estimated_minutes": 60 }
          ]
        }
      ],
      "habits": [
        { "title": "2 Hours GPU Code Lab", "frequency": "DAILY_MORNING" }
      ]
    }
  ]
}
```

---

### 2. `POST /functions/v1/ai-nightly-retrospective`
Analyzes daily execution telemetry and returns trajectory insights with tomorrow's recommended time-blocks.

#### Request Payload
```json
{
  "review_date": "2026-09-02",
  "energy_level": 4,
  "focus_sessions": [
    { "task_id": "...", "duration_seconds": 5400, "focus_quality_score": 9.5 }
  ],
  "completed_tasks": ["..."],
  "postponed_tasks": [
    { "task_id": "...", "title": "Refactor CUDA kernel memory layout", "reason": "Scope larger than estimated" }
  ],
  "habits_completed": ["..."]
}
```

#### Response Payload (200 OK)
```json
{
  "assessment_markdown": "Strong focus discipline today with 90 minutes of uninterrupted deep work on Triton kernels. High output observed in morning flow window.",
  "friction_diagnosis": "Task 'Refactor CUDA kernel memory layout' stalled due to under-estimated scope. Recommended splitting into 2 atomic subtasks.",
  "recommended_schedule": [
    { "time": "06:30 - 08:30", "task_title": "CUDA memory layout: Part 1 Tiling", "cognitive_tier": "DEEP_3X" },
    { "time": "08:45 - 09:15", "task_title": "Daily Habit: Paper Review", "cognitive_tier": "MEDIUM_2X" }
  ]
}
```

---

### 3. `POST /functions/v1/semantic-search`
Performs cosine distance search over vector embeddings in `knowledge_notes`.

#### Request Payload
```json
{
  "query": "Triton shared memory bank conflicts",
  "match_threshold": 0.75,
  "match_count": 5
}
```

#### Response Payload (200 OK)
```json
{
  "results": [
    {
      "id": "e4a7b1c3-2289-4d2b-8a88-123456789abc",
      "title": "GPU Shared Memory Architecture Notes",
      "snippet": "Shared memory is divided into 32 equal-sized banks. Bank conflicts occur when multiple threads in a warp access...",
      "similarity": 0.892
    }
  ]
}
```

---

## 3. PostgreSQL Stored Procedures (RPCs)

### 1. `rpc/recalculate_goal_progress`
Recalculates the weighted completion percentage of a goal based on its milestones and child tasks.
- **Parameters**: `goal_id (UUID)`
- **Returns**: `NUMERIC(5, 2)` (New weighted percentage)

### 2. `rpc/get_dashboard_telemetry`
Aggregates today's focus hours, habit completion rate, and active next-action in a single round-trip.
- **Parameters**: `user_id (UUID)`
- **Returns**: JSON object containing `focus_hours_today`, `habit_score`, `velocity_delta`, `hero_task`.

---

## 4. Supabase Realtime Channels

- **Channel `realtime:user_state:<user_id>`**: Broadcasts real-time updates when tasks, habits, or focus sessions are modified across multiple devices.
- **Channel `realtime:war_room:<room_id>`**: Coordinates shared peer study sessions, live focus timers, and silent accountability metrics.
