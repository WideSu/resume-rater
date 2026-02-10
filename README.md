# ResuMatch

ResuMatch is an intelligent resume analysis and optimization tool designed to bridge the gap between job descriptions and candidate profiles. It features automated keyword extraction, real-time match scoring, a version-controlled resume editor, and personalized interview question generation. Built with React and Supabase, it helps job seekers tailor their applications and prepare effectively for technical interviews.

## How to Run

1. **Install Dependencies**
   ```bash
   npm install
   ```

2. **Configure Environment**
   Copy the example environment file and add your Supabase credentials:
   ```bash
   cp .env.example .env
   ```
   *Note: You will need a valid `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY`.*

3. **Start Development Server**
   ```bash
   npm run dev
   ```
