# Arete OS — Feature Specifications and Mathematical Models

---

## 1. Goal Engine and Decomposition Architecture

### Mathematical Model of Goal Hierarchy
Goals in Arete are not linear checklists. They are modeled as a **Weighted Directed Acyclic Graph (DAG)** where completion propagates mathematically from atomic tasks up to the root identity goal.

$$Progress(G) = \sum_{i=1}^{n} \left( W(M_i) \times Progress(M_i) \right)$$

Where:
- $G$ is the Goal.
- $M_i$ is the $i$-th Milestone belonging to Goal $G$.
- $W(M_i)$ is the normalized weight of Milestone $M_i$ such that $\sum W(M_i) = 1.0$.
- $Progress(M_i) = \frac{\sum_{j=1}^{m} \text{CompletedTasks}(P_{ij})}{\text{TotalTasks}(P_{ij})}$.

### Completion Prediction Algorithm
The system computes an estimated completion date using an Exponential Moving Average (EMA) of velocity:

$$Velocity_{EMA}(t) = \alpha \times Velocity(t) + (1 - \alpha) \times Velocity_{EMA}(t-1)$$

$$\text{Projected Days Remaining} = \frac{\text{Remaining Weighted Effort Units}}{Velocity_{EMA}}$$

If $\text{Projected Date} > \text{Target Deadline}$, the milestone is marked with an **Amber Friction Flag** and surfaced to the AI Coach for scope rebalancing.

---

## 2. Next-Action Recommendation Engine

The Mission Control Dashboard surfaces a single primary "Next Action" to eliminate decision paralysis. The recommendation score $S(T)$ for each task $T$ is computed dynamically:

$$S(T) = \frac{P(T) \times U(T) \times E_{fit}(T)}{1 + D(T)}$$

Where:
- $P(T)$ is Priority Weight (P0 = 4.0, P1 = 2.0, P2 = 1.0).
- $U(T)$ is Urgency / Deadline Proximity factor: $U(T) = \frac{1}{\max(1, \text{Days Until Milestone Deadline})}$.
- $E_{fit}(T)$ is Energy Level Fit: Matching the user's declared energy (1 to 5) with task cognitive demand (Deep = 3, Medium = 2, Shallow = 1).
- $D(T)$ is Dependency Penalty ($D(T) = \infty$ if blocked by unfinished prerequisite tasks; $0$ if unblocked).

---

## 3. Habit Engine and Consistency Vector Model

Traditional habit streaks induce psychological guilt when broken by unavoidable circumstances. Arete models habits using a **30-Day Rolling Consistency Vector**:

$$Consistency_{30} = \frac{1}{30} \sum_{k=0}^{29} R(t - k) \times \gamma^k$$

Where:
- $R(t - k) \in \{0, 1\}$ represents habit completion on day $t-k$.
- $\gamma \in [0.95, 1.0]$ is a recency attenuation factor.
- A single missed day lowers consistency marginally from $100\%$ to $96.8\%$ rather than resetting the entire metric to zero, preserving momentum while encouraging immediate resumption.

---

## 4. Focus Mode and Deep Work Acoustic Engine

### State Machine Architecture
Focus Mode operates on a strict 4-state finite state machine:
```
[ IDLE ] ---> (Cmd + Enter) ---> [ ACTIVE DEEP WORK ]
                                         |
                                (Pause / Break Trigger)
                                         v
                                  [ MICRO RECOVERY ]
                                         |
                               (Resume or Complete)
                                         v
                                 [ SESSION COMPLETE ]
```

### Acoustic Soundscapes
Powered by Web Audio API / `just_audio_web` using seamless non-blocking buffer looping:
1. **Binaural 40Hz Gamma**: Modulated sine waves engineered to promote cognitive focus and binding.
2. **Deep Brown Noise**: Low-frequency $1/f^2$ spectral density for acoustic masking in loud environments.
3. **Obsidian Rain**: High-fidelity field audio filtered with a low-pass shelf to remove high-frequency hiss.
4. **Terminal Hum**: Low-amplitude 60Hz ambient server room resonance.

---

## 5. Analytics Engine & Friction Radar

### 1. Velocity vs Target Burn-Up Curve
- Plots cumulative completed effort units over time.
- Renders a 95% statistical confidence cone projecting future delivery boundaries based on historical variance.

### 2. Cognitive Output Heatmap
- Visualizes 24-hour horizontal bands showing focus session intensity against the hour of day.
- Identifies the user's personal "Golden Flow Hours" (e.g. 06:30 to 10:00).

### 3. Friction & Postponement Radar
- Detects tasks where `postpone_count >= 2` or time spent exceeds `estimated_time * 2.5`.
- Automatically tags the task as a "Cognitive Block" and queues a prompt for the nightly AI review to subdivide or delegate it.

---

## 6. Knowledge Base and Semantic Vector Indexing

### Knowledge Graph Architecture
- Rich text and markdown editing with live AST parsing.
- Bi-directional wiki-links (`[[Milestone: Triton FlashAttention]]`) resolved locally in sub-5ms.

### Semantic Search Pipeline
```
[ User Input Document / Note ]
               |
               v
[ Supabase Edge Function: Text Chunking (512 tokens with 64 token overlap) ]
               |
               v
[ OpenAI text-embedding-3-small / Gemini Embedding API ] (1536-dim vector)
               |
               v
[ PostgreSQL 16 + pgvector HNSW Index (Cosine Distance) ]
               |
               v
[ Sub-10ms Semantic Nearest Neighbor Retrieval ]
```

---

## 7. AI Cognitive Coach Architecture

### Execution Cadence
- **Trigger**: Automated nightly cron at 22:00 local time or manual user trigger via `Cmd+K -> Nightly Review`.
- **Input Context Payload**:
  - Logged focus sessions (durations, task IDs, interruption counts).
  - Completed habits vs scheduled habits.
  - Postponed or stalled tasks.
  - Active milestones nearing deadline.
  - Declared subjective energy score (1 to 5).
- **Edge Function Pipeline**:
  - Analyzes productivity trajectory without sycophancy or fluff.
  - Generates a 3-part structured JSON payload:
    1. `daily_assessment`: Concise analysis of actual output vs planned output.
    2. `friction_diagnosis`: Identified psychological or technical blockers.
    3. `recommended_schedule`: Proposed time-blocks and priority tasks for tomorrow.

---

## 8. Universal Command Engine (`Cmd+K`)

### Indexing and Dispatch Architecture
- **In-Memory Trie & Fuzzy Index**: Pre-indexes all Goals, Milestones, Projects, Tasks, Notes, and System Actions into local Web Worker memory.
- **Query Execution**: Sub-16ms fuzzy matching using modified Levenshtein distance with prefix priority.
- **Action Grammar**:
  - `> create task [Title] @milestone #priority`
  - `> focus [30|45|60|90]`
  - `> habit check [Habit Name]`
  - `> goto [Module Name]`
