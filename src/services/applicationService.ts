
import { supabase } from '@/lib/supabase';
import { v4 as uuidv4 } from 'uuid';

export interface JobApplication {
  id: string;
  company_name: string;
  job_title: string;
  jd_link: string;
  jd_content: string;
  created_at: string;
  updated_at: string;
}

export const applicationService = {
  async getAll() {
    const { data: { user } } = await supabase.auth.getUser();
    
    if (!user) return []; // Return empty if not logged in

    const { data, error } = await supabase
      .from('job_applications')
      .select('*')
      .eq('user_id', user.id)
      .order('created_at', { ascending: false });
      
    if (error) throw error;
    return data as JobApplication[];
  },

  async getById(id: string) {
    const { data, error } = await supabase
      .from('job_applications')
      .select('*')
      .eq('id', id)
      .single();
      
    if (error) throw error;
    return data as JobApplication;
  },

  async save(application: Partial<JobApplication> & { resume_content?: string }) {
    const { data: { user } } = await supabase.auth.getUser();
    
    if (!user) throw new Error('You must be logged in to save applications.');

    // Ensure user exists in public.users table (Client-side sync for MVP)
    const { error: userError } = await supabase
        .from('users')
        .upsert({ id: user.id, email: user.email }, { onConflict: 'id' });
    
    if (userError) {
        console.error('Error syncing user:', userError);
        // Continue anyway, it might already exist or RLS might handle it
    }
    
    const payload = {
      company_name: application.company_name || 'Untitled Company',
      job_title: application.job_title || 'Untitled Job',
      jd_link: application.jd_link || '',
      jd_content: application.jd_content || '',
      updated_at: new Date().toISOString(),
      user_id: user.id
    };

    let result;
    if (application.id) {
        // Update
        result = await supabase
            .from('job_applications')
            .update(payload)
            .eq('id', application.id)
            .select()
            .single();
    } else {
        // Insert
        result = await supabase
            .from('job_applications')
            .insert([payload])
            .select()
            .single();
    }

    if (result.error) throw result.error;
    
    const appId = result.data.id;

    // Also save the resume as a version if provided
    if (application.resume_content) {
        await supabase.from('resume_versions').insert([{
            application_id: appId,
            content: application.resume_content,
            version_number: 1 // Simplified versioning for now
        }]);
    }

    return result.data;
  },
  
  // Helper to get the latest resume for an application
  async getLatestResume(applicationId: string) {
      const { data, error } = await supabase
        .from('resume_versions')
        .select('content')
        .eq('application_id', applicationId)
        .order('created_at', { ascending: false })
        .limit(1)
        .single();
        
      if (error && error.code !== 'PGRST116') throw error; // Ignore not found
      return data?.content || '';
  }
};
