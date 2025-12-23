import 'package:habbit_island/core/errors/exceptions.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;

/// Supabase Client Manager
/// Handles Supabase initialization and provides configured client instance
/// Reference: Technical Addendum §2.2 (Supabase Integration)
///
/// PROJECT: Habbit_island
/// Database: PostgreSQL with Row Level Security (RLS) enabled

class SupabaseClientManager {
  // Singleton pattern
  static final SupabaseClientManager _instance =
      SupabaseClientManager._internal();
  factory SupabaseClientManager() => _instance;
  SupabaseClientManager._internal();

  // Replace with your actual Supabase credentials
  // Get these from: https://app.supabase.com/project/YOUR_PROJECT/settings/api
  static const String _supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String _supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  SupabaseClient? _client;
  bool _isInitialized = false;

  /// Initialize Supabase
  /// Call this in main() before runApp()
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      await Supabase.initialize(
        url: _supabaseUrl,
        anonKey: _supabaseAnonKey,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
        realtimeClientOptions: const RealtimeClientOptions(
          logLevel: RealtimeLogLevel.info,
        ),
        storageOptions: const StorageClientOptions(retryAttempts: 3),
      );

      _client = Supabase.instance.client;
      _isInitialized = true;
    } catch (e) {
      throw ServerException('Failed to initialize Supabase: $e');
    }
  }

  /// Get Supabase client instance
  SupabaseClient get client {
    if (!_isInitialized || _client == null) {
      throw ServerException('Supabase not initialized. Call init() first.');
    }
    return _client!;
  }

  /// Get current user
  User? get currentUser => client.auth.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  /// Get user ID
  String? get userId => currentUser?.id;

  /// Sign out
  Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } catch (e) {
      throw AuthException('Failed to sign out: $e');
    }
  }
}

// ============================================================================
// SUPABASE DATABASE SCHEMA & RLS POLICIES
// ============================================================================

/*
============================================================================
TABLE: users
============================================================================
CREATE TABLE users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  display_name TEXT,
  photo_url TEXT,
  is_premium BOOLEAN DEFAULT FALSE,
  premium_tier TEXT,
  premium_expires_at TIMESTAMPTZ,
  total_xp INTEGER DEFAULT 0,
  current_level INTEGER DEFAULT 1,
  total_habits INTEGER DEFAULT 0,
  active_habits INTEGER DEFAULT 0,
  total_completions INTEGER DEFAULT 0,
  longest_streak INTEGER DEFAULT 0,
  current_global_streak INTEGER DEFAULT 0,
  current_island_id UUID NOT NULL,
  unlocked_zone_ids TEXT[] DEFAULT ARRAY[]::TEXT[],
  streak_shields_remaining INTEGER DEFAULT 0,
  vacation_days_remaining INTEGER DEFAULT 0,
  last_login_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  last_synced_at TIMESTAMPTZ
);

-- RLS Policies for users table
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Users can read their own data
CREATE POLICY "Users can view own data" ON users
  FOR SELECT USING (auth.uid() = id);

-- Users can update their own data
CREATE POLICY "Users can update own data" ON users
  FOR UPDATE USING (auth.uid() = id);

-- Users can insert their own data (on signup)
CREATE POLICY "Users can insert own data" ON users
  FOR INSERT WITH CHECK (auth.uid() = id);

============================================================================
TABLE: habits
============================================================================
CREATE TABLE habits (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  icon TEXT,
  category TEXT NOT NULL,
  frequency TEXT NOT NULL,
  specific_days INTEGER[],
  reminder_time TIMESTAMPTZ,
  zone_id TEXT NOT NULL,
  current_streak INTEGER DEFAULT 0,
  longest_streak INTEGER DEFAULT 0,
  total_completions INTEGER DEFAULT 0,
  current_xp INTEGER DEFAULT 0,
  growth_level TEXT DEFAULT 'level1',
  decay_state TEXT DEFAULT 'healthy',
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  last_completed_at TIMESTAMPTZ,
  last_synced_at TIMESTAMPTZ
);

-- Index for faster queries
CREATE INDEX habits_user_id_idx ON habits(user_id);
CREATE INDEX habits_zone_id_idx ON habits(zone_id);
CREATE INDEX habits_is_active_idx ON habits(is_active);

-- RLS Policies for habits table
ALTER TABLE habits ENABLE ROW LEVEL SECURITY;

-- Users can read their own habits
CREATE POLICY "Users can view own habits" ON habits
  FOR SELECT USING (auth.uid() = user_id);

-- Users can insert their own habits
CREATE POLICY "Users can insert own habits" ON habits
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can update their own habits
CREATE POLICY "Users can update own habits" ON habits
  FOR UPDATE USING (auth.uid() = user_id);

-- Users can delete their own habits
CREATE POLICY "Users can delete own habits" ON habits
  FOR DELETE USING (auth.uid() = user_id);

============================================================================
TABLE: habit_completions
============================================================================
CREATE TABLE habit_completions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  habit_id UUID NOT NULL REFERENCES habits(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  completed_at TIMESTAMPTZ NOT NULL,
  logical_date DATE NOT NULL,
  xp_earned INTEGER NOT NULL DEFAULT 10,
  was_bonus_day BOOLEAN DEFAULT FALSE,
  was_milestone BOOLEAN DEFAULT FALSE,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  synced_at TIMESTAMPTZ
);

-- Indexes for faster queries
CREATE INDEX completions_habit_id_idx ON habit_completions(habit_id);
CREATE INDEX completions_user_id_idx ON habit_completions(user_id);
CREATE INDEX completions_logical_date_idx ON habit_completions(logical_date);

-- Prevent duplicate completions per day
CREATE UNIQUE INDEX completions_habit_date_unique 
  ON habit_completions(habit_id, logical_date);

-- RLS Policies for habit_completions table
ALTER TABLE habit_completions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own completions" ON habit_completions
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own completions" ON habit_completions
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own completions" ON habit_completions
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own completions" ON habit_completions
  FOR DELETE USING (auth.uid() = user_id);

============================================================================
TABLE: habit_streaks
============================================================================
-- This is a computed/cached table - always recalculate from completions
CREATE TABLE habit_streaks (
  habit_id UUID PRIMARY KEY REFERENCES habits(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  current_streak INTEGER DEFAULT 0,
  longest_streak INTEGER DEFAULT 0,
  current_streak_start_date DATE,
  longest_streak_start_date DATE,
  longest_streak_end_date DATE,
  last_completion_date DATE,
  total_completions INTEGER DEFAULT 0,
  completions_this_week INTEGER DEFAULT 0,
  completions_this_month INTEGER DEFAULT 0,
  completions_this_year INTEGER DEFAULT 0,
  milestones_days INTEGER[] DEFAULT ARRAY[]::INTEGER[],
  is_active BOOLEAN DEFAULT FALSE,
  calculated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX streaks_user_id_idx ON habit_streaks(user_id);

-- RLS Policies
ALTER TABLE habit_streaks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own streaks" ON habit_streaks
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own streaks" ON habit_streaks
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own streaks" ON habit_streaks
  FOR UPDATE USING (auth.uid() = user_id);

============================================================================
TABLE: premium_entitlements
============================================================================
CREATE TABLE premium_entitlements (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  tier TEXT NOT NULL,
  platform TEXT NOT NULL,
  transaction_id TEXT,
  product_id TEXT,
  purchased_at TIMESTAMPTZ NOT NULL,
  expires_at TIMESTAMPTZ,
  cancelled_at TIMESTAMPTZ,
  is_active BOOLEAN DEFAULT TRUE,
  auto_renews BOOLEAN DEFAULT FALSE,
  streak_shields_total INTEGER DEFAULT 3,
  streak_shields_used INTEGER DEFAULT 0,
  streak_shields_reset_at TIMESTAMPTZ,
  vacation_days_total INTEGER DEFAULT 30,
  vacation_days_used INTEGER DEFAULT 0,
  vacation_days_reset_at TIMESTAMPTZ,
  metadata JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX premium_user_id_idx ON premium_entitlements(user_id);

-- RLS Policies
ALTER TABLE premium_entitlements ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own premium" ON premium_entitlements
  FOR SELECT USING (auth.uid() = user_id);

============================================================================
TABLE: xp_events
============================================================================
CREATE TABLE xp_events (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  type TEXT NOT NULL,
  xp_amount INTEGER NOT NULL,
  habit_id UUID REFERENCES habits(id) ON DELETE SET NULL,
  related_id UUID,
  description TEXT,
  metadata JSONB,
  earned_at TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX xp_events_user_id_idx ON xp_events(user_id);
CREATE INDEX xp_events_earned_at_idx ON xp_events(earned_at);

-- RLS Policies
ALTER TABLE xp_events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own xp events" ON xp_events
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own xp events" ON xp_events
  FOR INSERT WITH CHECK (auth.uid() = user_id);

============================================================================
TABLE: island_states
============================================================================
CREATE TABLE island_states (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  theme TEXT DEFAULT 'tropical',
  zones JSONB NOT NULL,
  current_weather TEXT NOT NULL,
  overall_completion_rate NUMERIC(3,2) NOT NULL,
  total_xp INTEGER DEFAULT 0,
  last_updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX island_user_id_idx ON island_states(user_id);

-- RLS Policies
ALTER TABLE island_states ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own islands" ON island_states
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own islands" ON island_states
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own islands" ON island_states
  FOR UPDATE USING (auth.uid() = user_id);

============================================================================
TRIGGER: updated_at timestamp
============================================================================
-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Add triggers to tables
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_habits_updated_at BEFORE UPDATE ON habits
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_premium_updated_at BEFORE UPDATE ON premium_entitlements
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

============================================================================
*/
