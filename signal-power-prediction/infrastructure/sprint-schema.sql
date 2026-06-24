-- Level-Game Sprint Tracking Database Schema
-- Signal Power Prediction System
-- CODE RED Infrastructure

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Sprint Status Enum
CREATE TYPE sprint_status AS ENUM (
    'planning',
    'active',
    'review',
    'completed',
    'failed',
    'aborted'
);

-- Level Status Enum
CREATE TYPE level_status AS ENUM (
    'locked',
    'unlocked',
    'in_progress',
    'completed',
    'failed'
);

-- Agent Role Enum
CREATE TYPE agent_role AS ENUM (
    'architect',
    'builder',
    'reviewer',
    'tester',
    'coordinator',
    'specialist'
);

-- Task Priority Enum
CREATE TYPE task_priority AS ENUM (
    'critical',
    'high',
    'medium',
    'low'
);

-- Task Status Enum
CREATE TYPE task_status AS ENUM (
    'pending',
    'assigned',
    'in_progress',
    'blocked',
    'completed',
    'failed'
);

-- ============================================
-- CORE TABLES
-- ============================================

-- Sprints table - tracks each level-game sprint
CREATE TABLE sprints (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    level_number INTEGER NOT NULL,
    level_name VARCHAR(255) NOT NULL,
    status sprint_status DEFAULT 'planning',
    
    -- Objectives
    primary_objective TEXT NOT NULL,
    success_criteria JSONB NOT NULL,
    deliverables JSONB NOT NULL,
    
    -- Timing
    planned_start_at TIMESTAMP WITH TIME ZONE,
    started_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    deadline_at TIMESTAMP WITH TIME ZONE,
    
    -- Progress tracking
    total_tasks INTEGER DEFAULT 0,
    completed_tasks INTEGER DEFAULT 0,
    progress_percent INTEGER DEFAULT 0,
    
    -- XP and rewards
    base_xp INTEGER DEFAULT 100,
    bonus_xp INTEGER DEFAULT 0,
    total_xp INTEGER GENERATED ALWAYS AS (base_xp + bonus_xp) STORED,
    
    -- Metadata
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by VARCHAR(255),
    tags JSONB DEFAULT '[]',
    
    -- Constraints
    CONSTRAINT positive_level CHECK (level_number > 0),
    CONSTRAINT valid_progress CHECK (progress_percent BETWEEN 0 AND 100)
);

-- Levels table - defines each level in the game
CREATE TABLE levels (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    level_number INTEGER UNIQUE NOT NULL,
    level_name VARCHAR(255) NOT NULL,
    description TEXT,
    
    -- Requirements
    prerequisites JSONB DEFAULT '[]', -- Array of level_numbers required
    required_xp INTEGER DEFAULT 0,
    
    -- Status
    status level_status DEFAULT 'locked',
    unlocked_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    
    -- Configuration
    config JSONB DEFAULT '{}', -- Level-specific settings
    
    -- Metadata
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Agents table - registered agents in the system
CREATE TABLE agents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    agent_name VARCHAR(255) UNIQUE NOT NULL,
    agent_handle VARCHAR(100) UNIQUE NOT NULL, -- @handle format
    role agent_role NOT NULL,
    
    -- Stats
    level INTEGER DEFAULT 1,
    total_xp INTEGER DEFAULT 0,
    tasks_completed INTEGER DEFAULT 0,
    tasks_failed INTEGER DEFAULT 0,
    
    -- Capabilities
    skills JSONB DEFAULT '[]',
    specializations JSONB DEFAULT '[]',
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    last_seen_at TIMESTAMP WITH TIME ZONE,
    
    -- Metadata
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tasks table - individual tasks within sprints
CREATE TABLE tasks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sprint_id UUID NOT NULL REFERENCES sprints(id) ON DELETE CASCADE,
    parent_task_id UUID REFERENCES tasks(id) ON DELETE CASCADE,
    
    -- Task details
    title VARCHAR(500) NOT NULL,
    description TEXT,
    task_type VARCHAR(100), -- code, review, test, design, etc.
    priority task_priority DEFAULT 'medium',
    status task_status DEFAULT 'pending',
    
    -- Assignment
    assigned_to UUID REFERENCES agents(id),
    assigned_at TIMESTAMP WITH TIME ZONE,
    
    -- Estimation
    estimated_hours DECIMAL(5,2),
    actual_hours DECIMAL(5,2),
    
    -- Timing
    started_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    deadline_at TIMESTAMP WITH TIME ZONE,
    
    -- Rewards
    xp_reward INTEGER DEFAULT 10,
    
    -- Dependencies
    dependencies JSONB DEFAULT '[]', -- Array of task_ids
    
    -- Results
    result_summary TEXT,
    artifacts JSONB DEFAULT '[]', -- Array of file paths/URLs
    
    -- Metadata
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by VARCHAR(255),
    
    -- Ordering
    display_order INTEGER DEFAULT 0
);

-- Sprint Participants - agents assigned to sprints
CREATE TABLE sprint_participants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sprint_id UUID NOT NULL REFERENCES sprints(id) ON DELETE CASCADE,
    agent_id UUID NOT NULL REFERENCES agents(id) ON DELETE CASCADE,
    
    role_in_sprint agent_role NOT NULL,
    is_lead BOOLEAN DEFAULT false,
    
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    left_at TIMESTAMP WITH TIME ZONE,
    
    tasks_assigned INTEGER DEFAULT 0,
    tasks_completed INTEGER DEFAULT 0,
    xp_earned INTEGER DEFAULT 0,
    
    UNIQUE(sprint_id, agent_id)
);

-- Sprint Events - audit log for all sprint activities
CREATE TABLE sprint_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sprint_id UUID NOT NULL REFERENCES sprints(id) ON DELETE CASCADE,
    
    event_type VARCHAR(100) NOT NULL, -- task_created, task_completed, level_up, etc.
    event_data JSONB DEFAULT '{}',
    
    triggered_by UUID REFERENCES agents(id),
    triggered_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- For agent coordination
    requires_action BOOLEAN DEFAULT false,
    action_taken_by UUID REFERENCES agents(id),
    action_taken_at TIMESTAMP WITH TIME ZONE
);

-- Agent XP History
CREATE TABLE agent_xp_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    agent_id UUID NOT NULL REFERENCES agents(id) ON DELETE CASCADE,
    sprint_id UUID REFERENCES sprints(id) ON DELETE SET NULL,
    task_id UUID REFERENCES tasks(id) ON DELETE SET NULL,
    
    xp_amount INTEGER NOT NULL,
    xp_type VARCHAR(100), -- task_completion, bonus, level_bonus, etc.
    reason TEXT,
    
    awarded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    awarded_by VARCHAR(255)
);

-- Level Progression History
CREATE TABLE level_progression (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    agent_id UUID NOT NULL REFERENCES agents(id) ON DELETE CASCADE,
    
    from_level INTEGER NOT NULL,
    to_level INTEGER NOT NULL,
    
    xp_at_level_up INTEGER NOT NULL,
    sprint_id UUID REFERENCES sprints(id),
    
    leveled_up_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- CI/CD Pipeline Runs
CREATE TABLE pipeline_runs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sprint_id UUID REFERENCES sprints(id) ON DELETE SET NULL,
    
    pipeline_name VARCHAR(255) NOT NULL,
    run_number INTEGER NOT NULL,
    
    status VARCHAR(50) DEFAULT 'pending', -- pending, running, success, failed
    
    started_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    duration_seconds INTEGER,
    
    commit_sha VARCHAR(40),
    branch VARCHAR(255),
    
    results JSONB DEFAULT '{}',
    logs_url TEXT,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- INDEXES
-- ============================================

CREATE INDEX idx_sprints_status ON sprints(status);
CREATE INDEX idx_sprints_level ON sprints(level_number);
CREATE INDEX idx_sprints_active ON sprints(status) WHERE status IN ('planning', 'active', 'review');

CREATE INDEX idx_levels_number ON levels(level_number);
CREATE INDEX idx_levels_status ON levels(status);

CREATE INDEX idx_agents_handle ON agents(agent_handle);
CREATE INDEX idx_agents_role ON agents(role);
CREATE INDEX idx_agents_active ON agents(is_active) WHERE is_active = true;

CREATE INDEX idx_tasks_sprint ON tasks(sprint_id);
CREATE INDEX idx_tasks_assigned ON tasks(assigned_to);
CREATE INDEX idx_tasks_status ON tasks(status);
CREATE INDEX idx_tasks_priority ON tasks(priority);

CREATE INDEX idx_events_sprint ON sprint_events(sprint_id);
CREATE INDEX idx_events_type ON sprint_events(event_type);
CREATE INDEX idx_events_time ON sprint_events(triggered_at);

CREATE INDEX idx_xp_agent ON agent_xp_history(agent_id);
CREATE INDEX idx_xp_sprint ON agent_xp_history(sprint_id);

-- ============================================
-- VIEWS
-- ============================================

-- Active sprints view
CREATE VIEW active_sprints AS
SELECT s.*, 
       COUNT(t.id) FILTER (WHERE t.status = 'completed') as done_tasks,
       COUNT(t.id) FILTER (WHERE t.status IN ('pending', 'assigned', 'in_progress')) as pending_tasks
FROM sprints s
LEFT JOIN tasks t ON t.sprint_id = s.id
WHERE s.status IN ('planning', 'active', 'review')
GROUP BY s.id;

-- Agent leaderboard view
CREATE VIEW agent_leaderboard AS
SELECT 
    a.id,
    a.agent_name,
    a.agent_handle,
    a.role,
    a.level,
    a.total_xp,
    a.tasks_completed,
    RANK() OVER (ORDER BY a.total_xp DESC) as rank
FROM agents a
WHERE a.is_active = true;

-- Sprint progress view
CREATE VIEW sprint_progress AS
SELECT 
    s.id,
    s.level_number,
    s.level_name,
    s.status,
    COUNT(t.id) as total_tasks,
    COUNT(t.id) FILTER (WHERE t.status = 'completed') as completed_tasks,
    COUNT(t.id) FILTER (WHERE t.status = 'failed') as failed_tasks,
    COUNT(t.id) FILTER (WHERE t.status IN ('in_progress', 'assigned')) as active_tasks,
    ROUND(
        COUNT(t.id) FILTER (WHERE t.status = 'completed') * 100.0 / NULLIF(COUNT(t.id), 0), 
        2
    ) as completion_percent
FROM sprints s
LEFT JOIN tasks t ON t.sprint_id = s.id
GROUP BY s.id;

-- ============================================
-- FUNCTIONS & TRIGGERS
-- ============================================

-- Update timestamps automatically
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_sprints_updated_at BEFORE UPDATE ON sprints
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_levels_updated_at BEFORE UPDATE ON levels
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_agents_updated_at BEFORE UPDATE ON agents
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_tasks_updated_at BEFORE UPDATE ON tasks
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Auto-update sprint progress
CREATE OR REPLACE FUNCTION update_sprint_progress()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE sprints
    SET 
        total_tasks = (SELECT COUNT(*) FROM tasks WHERE sprint_id = COALESCE(NEW.sprint_id, OLD.sprint_id)),
        completed_tasks = (SELECT COUNT(*) FROM tasks WHERE sprint_id = COALESCE(NEW.sprint_id, OLD.sprint_id) AND status = 'completed'),
        progress_percent = (
            SELECT COALESCE(ROUND(COUNT(*) FILTER (WHERE status = 'completed') * 100.0 / NULLIF(COUNT(*), 0)), 0)
            FROM tasks 
            WHERE sprint_id = COALESCE(NEW.sprint_id, OLD.sprint_id)
        ),
        updated_at = NOW()
    WHERE id = COALESCE(NEW.sprint_id, OLD.sprint_id);
    
    RETURN COALESCE(NEW, OLD);
END;
$$ language 'plpgsql';

CREATE TRIGGER update_sprint_progress_on_task_change
    AFTER INSERT OR UPDATE OR DELETE ON tasks
    FOR EACH ROW EXECUTE FUNCTION update_sprint_progress();

-- Award XP to agent
CREATE OR REPLACE FUNCTION award_agent_xp(
    p_agent_id UUID,
    p_xp_amount INTEGER,
    p_xp_type VARCHAR,
    p_reason TEXT,
    p_sprint_id UUID DEFAULT NULL,
    p_task_id UUID DEFAULT NULL,
    p_awarded_by VARCHAR DEFAULT 'system'
)
RETURNS VOID AS $$
DECLARE
    v_current_xp INTEGER;
    v_current_level INTEGER;
    v_new_level INTEGER;
BEGIN
    -- Record XP
    INSERT INTO agent_xp_history (agent_id, sprint_id, task_id, xp_amount, xp_type, reason, awarded_by)
    VALUES (p_agent_id, p_sprint_id, p_task_id, p_xp_amount, p_xp_type, p_reason, p_awarded_by);
    
    -- Update agent total XP
    UPDATE agents 
    SET total_xp = total_xp + p_xp_amount,
        tasks_completed = CASE WHEN p_xp_type = 'task_completion' THEN tasks_completed + 1 ELSE tasks_completed END
    WHERE id = p_agent_id
    RETURNING total_xp, level INTO v_current_xp, v_current_level;
    
    -- Check for level up (simple formula: level * 100 XP per level)
    v_new_level := FLOOR(SQRT(v_current_xp / 100.0)) + 1;
    
    IF v_new_level > v_current_level THEN
        UPDATE agents SET level = v_new_level WHERE id = p_agent_id;
        
        INSERT INTO level_progression (agent_id, from_level, to_level, xp_at_level_up, sprint_id)
        VALUES (p_agent_id, v_current_level, v_new_level, v_current_xp, p_sprint_id);
        
        -- Create level up event
        INSERT INTO sprint_events (sprint_id, event_type, event_data, triggered_by)
        VALUES (p_sprint_id, 'agent_level_up', 
                jsonb_build_object('agent_id', p_agent_id, 'new_level', v_new_level),
                p_agent_id);
    END IF;
END;
$$ language 'plpgsql';

-- Complete sprint and award bonus XP
CREATE OR REPLACE FUNCTION complete_sprint(p_sprint_id UUID)
RETURNS VOID AS $$
DECLARE
    v_sprint_record RECORD;
    v_participant RECORD;
BEGIN
    SELECT * INTO v_sprint_record FROM sprints WHERE id = p_sprint_id;
    
    IF v_sprint_record.status != 'completed' THEN
        -- Mark sprint complete
        UPDATE sprints 
        SET status = 'completed', 
            completed_at = NOW(),
            progress_percent = 100
        WHERE id = p_sprint_id;
        
        -- Award bonus XP to all participants
        FOR v_participant IN 
            SELECT sp.*, a.id as agent_uuid 
            FROM sprint_participants sp
            JOIN agents a ON a.id = sp.agent_id
            WHERE sp.sprint_id = p_sprint_id
        LOOP
            PERFORM award_agent_xp(
                v_participant.agent_uuid,
                v_sprint_record.bonus_xp / GREATEST((SELECT COUNT(*) FROM sprint_participants WHERE sprint_id = p_sprint_id), 1),
                'sprint_bonus',
                'Sprint completion bonus: ' || v_sprint_record.level_name,
                p_sprint_id,
                NULL,
                'system'
            );
        END LOOP;
        
        -- Create completion event
        INSERT INTO sprint_events (sprint_id, event_type, event_data)
        VALUES (p_sprint_id, 'sprint_completed', 
                jsonb_build_object('level_number', v_sprint_record.level_number));
    END IF;
END;
$$ language 'plpgsql';

-- ============================================
-- SEED DATA
-- ============================================

-- Seed levels
INSERT INTO levels (level_number, level_name, description, required_xp, config) VALUES
(1, 'Initiate', 'First steps into the system', 0, '{"max_agents": 2, "difficulty": "easy"}'),
(2, 'Apprentice', 'Building foundational skills', 100, '{"max_agents": 3, "difficulty": "easy"}'),
(3, 'Journeyman', 'Complex problem solving', 300, '{"max_agents": 4, "difficulty": "medium"}'),
(4, 'Specialist', 'Domain expertise', 600, '{"max_agents": 5, "difficulty": "medium"}'),
(5, 'Expert', 'Leading sprints', 1000, '{"max_agents": 6, "difficulty": "hard"}'),
(6, 'Master', 'Architecting solutions', 1500, '{"max_agents": 8, "difficulty": "hard"}'),
(7, 'Grandmaster', 'System-wide impact', 2100, '{"max_agents": 10, "difficulty": "expert"}'),
(8, 'Legend', 'Transformative achievements', 2800, '{"max_agents": 12, "difficulty": "expert"}'),
(9, 'Mythic', 'Beyond conventional limits', 3600, '{"max_agents": 15, "difficulty": "legendary"}'),
(10, 'Transcendent', 'The pinnacle', 4500, '{"max_agents": 20, "difficulty": "legendary"}');

-- Unlock level 1
UPDATE levels SET status = 'unlocked', unlocked_at = NOW() WHERE level_number = 1;
