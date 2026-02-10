-- Drop existing permissive policies
DROP POLICY IF EXISTS "Enable access for all users" ON users;
DROP POLICY IF EXISTS "Enable access for all users" ON job_applications;
DROP POLICY IF EXISTS "Enable access for all users" ON resume_versions;
DROP POLICY IF EXISTS "Enable access for all users" ON analysis_history;

-- 1. Users Table Policies
-- Users can view their own profile
CREATE POLICY "Users can view own profile" ON users
FOR SELECT USING (auth.uid() = id);

-- Users can insert their own profile (during sign up sync)
CREATE POLICY "Users can insert own profile" ON users
FOR INSERT WITH CHECK (auth.uid() = id);

-- Users can update their own profile
CREATE POLICY "Users can update own profile" ON users
FOR UPDATE USING (auth.uid() = id);


-- 2. Job Applications Policies
-- Users can view their own applications
CREATE POLICY "Users can view own applications" ON job_applications
FOR SELECT USING (auth.uid() = user_id);

-- Users can insert their own applications
CREATE POLICY "Users can insert own applications" ON job_applications
FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can update their own applications
CREATE POLICY "Users can update own applications" ON job_applications
FOR UPDATE USING (auth.uid() = user_id);

-- Users can delete their own applications
CREATE POLICY "Users can delete own applications" ON job_applications
FOR DELETE USING (auth.uid() = user_id);


-- 3. Resume Versions Policies
-- Users can view versions of their own applications
CREATE POLICY "Users can view own resume versions" ON resume_versions
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM job_applications
    WHERE job_applications.id = resume_versions.application_id
    AND job_applications.user_id = auth.uid()
  )
);

-- Users can insert versions for their own applications
CREATE POLICY "Users can insert own resume versions" ON resume_versions
FOR INSERT WITH CHECK (
  EXISTS (
    SELECT 1 FROM job_applications
    WHERE job_applications.id = resume_versions.application_id
    AND job_applications.user_id = auth.uid()
  )
);

-- Users can update/delete (optional, usually versions are immutable or just add new ones)
CREATE POLICY "Users can delete own resume versions" ON resume_versions
FOR DELETE USING (
  EXISTS (
    SELECT 1 FROM job_applications
    WHERE job_applications.id = resume_versions.application_id
    AND job_applications.user_id = auth.uid()
  )
);


-- 4. Analysis History Policies
-- Users can view analysis of their own applications
CREATE POLICY "Users can view own analysis" ON analysis_history
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM job_applications
    WHERE job_applications.id = analysis_history.application_id
    AND job_applications.user_id = auth.uid()
  )
);

-- Users can insert analysis for their own applications
CREATE POLICY "Users can insert own analysis" ON analysis_history
FOR INSERT WITH CHECK (
  EXISTS (
    SELECT 1 FROM job_applications
    WHERE job_applications.id = analysis_history.application_id
    AND job_applications.user_id = auth.uid()
  )
);
