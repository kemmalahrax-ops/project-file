CREATE EXTENSION IF NOT EXISTS pgcrypto;


CREATE TABLE academic_terms (
	id UUID NOT NULL, 
	name VARCHAR(100) NOT NULL, 
	academic_year VARCHAR(20) NOT NULL, 
	start_date DATE NOT NULL, 
	end_date DATE NOT NULL, 
	status term_status NOT NULL, 
	created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	PRIMARY KEY (id), 
	CONSTRAINT ck_term_dates CHECK (end_date > start_date)
)

;


CREATE TABLE departments (
	id UUID NOT NULL, 
	name VARCHAR(200) NOT NULL, 
	code VARCHAR(30) NOT NULL, 
	description TEXT, 
	is_active BOOLEAN NOT NULL, 
	created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	PRIMARY KEY (id), 
	UNIQUE (name), 
	UNIQUE (code)
)

;


CREATE TABLE profiles (
	id UUID NOT NULL, 
	email VARCHAR(320) NOT NULL, 
	password_hash VARCHAR(255) NOT NULL, 
	first_name VARCHAR(100) NOT NULL, 
	last_name VARCHAR(100) NOT NULL, 
	role user_role NOT NULL, 
	matricule VARCHAR(100), 
	phone VARCHAR(40), 
	avatar_url TEXT, 
	status account_status NOT NULL, 
	activated_at TIMESTAMP WITH TIME ZONE, 
	last_login_at TIMESTAMP WITH TIME ZONE, 
	created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	PRIMARY KEY (id)
)

;


CREATE TABLE audit_logs (
	id UUID NOT NULL, 
	actor_id UUID, 
	action VARCHAR(100) NOT NULL, 
	entity_type VARCHAR(100) NOT NULL, 
	entity_id VARCHAR(100) NOT NULL, 
	old_value JSONB, 
	new_value JSONB, 
	request_metadata JSONB, 
	created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(actor_id) REFERENCES profiles (id) ON DELETE SET NULL
)

;


CREATE TABLE courses (
	id UUID NOT NULL, 
	code VARCHAR(50) NOT NULL, 
	title VARCHAR(255) NOT NULL, 
	description TEXT, 
	department_id UUID NOT NULL, 
	term_id UUID NOT NULL, 
	lecturer_id UUID NOT NULL, 
	is_active BOOLEAN NOT NULL, 
	created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	PRIMARY KEY (id), 
	CONSTRAINT uq_course_code_term UNIQUE (code, term_id), 
	FOREIGN KEY(department_id) REFERENCES departments (id) ON DELETE RESTRICT, 
	FOREIGN KEY(term_id) REFERENCES academic_terms (id) ON DELETE RESTRICT, 
	FOREIGN KEY(lecturer_id) REFERENCES profiles (id) ON DELETE RESTRICT
)

;


CREATE TABLE notifications (
	id UUID NOT NULL, 
	recipient_id UUID NOT NULL, 
	title VARCHAR(255) NOT NULL, 
	content TEXT NOT NULL, 
	notification_type VARCHAR(80) NOT NULL, 
	is_read BOOLEAN NOT NULL, 
	read_at TIMESTAMP WITH TIME ZONE, 
	created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(recipient_id) REFERENCES profiles (id) ON DELETE CASCADE
)

;


CREATE TABLE reports (
	id UUID NOT NULL, 
	created_by UUID NOT NULL, 
	report_type VARCHAR(80) NOT NULL, 
	filters JSONB, 
	file_url TEXT, 
	format VARCHAR(20) NOT NULL, 
	generated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(created_by) REFERENCES profiles (id) ON DELETE RESTRICT
)

;


CREATE TABLE ai_recommendations (
	id UUID NOT NULL, 
	student_id UUID NOT NULL, 
	course_id UUID, 
	recommendation TEXT NOT NULL, 
	evidence JSONB NOT NULL, 
	explanation TEXT, 
	model_name VARCHAR(150) NOT NULL, 
	review_status recommendation_review_status NOT NULL, 
	reviewed_by UUID, 
	created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(student_id) REFERENCES profiles (id) ON DELETE CASCADE, 
	FOREIGN KEY(course_id) REFERENCES courses (id) ON DELETE SET NULL, 
	FOREIGN KEY(reviewed_by) REFERENCES profiles (id) ON DELETE SET NULL
)

;


CREATE TABLE class_sections (
	id UUID NOT NULL, 
	course_id UUID NOT NULL, 
	name VARCHAR(100) NOT NULL, 
	capacity INTEGER, 
	is_active BOOLEAN NOT NULL, 
	created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	PRIMARY KEY (id), 
	CONSTRAINT uq_section_course_name UNIQUE (course_id, name), 
	FOREIGN KEY(course_id) REFERENCES courses (id) ON DELETE CASCADE
)

;


CREATE TABLE class_sessions (
	id UUID NOT NULL, 
	course_id UUID NOT NULL, 
	section_id UUID, 
	created_by UUID NOT NULL, 
	title VARCHAR(255) NOT NULL, 
	description TEXT, 
	room_id VARCHAR(120) NOT NULL, 
	scheduled_start TIMESTAMP WITH TIME ZONE NOT NULL, 
	scheduled_end TIMESTAMP WITH TIME ZONE NOT NULL, 
	actual_start TIMESTAMP WITH TIME ZONE, 
	actual_end TIMESTAMP WITH TIME ZONE, 
	status session_status NOT NULL, 
	recording_url TEXT, 
	created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(course_id) REFERENCES courses (id) ON DELETE CASCADE, 
	FOREIGN KEY(section_id) REFERENCES class_sections (id) ON DELETE SET NULL, 
	FOREIGN KEY(created_by) REFERENCES profiles (id) ON DELETE RESTRICT, 
	UNIQUE (room_id)
)

;


CREATE TABLE enrollments (
	id UUID NOT NULL, 
	student_id UUID NOT NULL, 
	course_id UUID NOT NULL, 
	section_id UUID, 
	status enrollment_status NOT NULL, 
	enrolled_on DATE DEFAULT CURRENT_DATE NOT NULL, 
	created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	PRIMARY KEY (id), 
	CONSTRAINT uq_enrollment_student_course_section UNIQUE (student_id, course_id, section_id), 
	FOREIGN KEY(student_id) REFERENCES profiles (id) ON DELETE CASCADE, 
	FOREIGN KEY(course_id) REFERENCES courses (id) ON DELETE CASCADE, 
	FOREIGN KEY(section_id) REFERENCES class_sections (id) ON DELETE SET NULL
)

;


CREATE TABLE ai_conversations (
	id UUID NOT NULL, 
	student_id UUID NOT NULL, 
	course_id UUID, 
	session_id UUID, 
	title VARCHAR(255), 
	is_archived BOOLEAN NOT NULL, 
	created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(student_id) REFERENCES profiles (id) ON DELETE CASCADE, 
	FOREIGN KEY(course_id) REFERENCES courses (id) ON DELETE SET NULL, 
	FOREIGN KEY(session_id) REFERENCES class_sessions (id) ON DELETE SET NULL
)

;


CREATE TABLE attendance_events (
	id UUID NOT NULL, 
	session_id UUID NOT NULL, 
	student_id UUID NOT NULL, 
	event_type attendance_event_type NOT NULL, 
	event_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	connection_id VARCHAR(255), 
	metadata JSONB, 
	PRIMARY KEY (id), 
	FOREIGN KEY(session_id) REFERENCES class_sessions (id) ON DELETE CASCADE, 
	FOREIGN KEY(student_id) REFERENCES profiles (id) ON DELETE CASCADE
)

;


CREATE TABLE chat_messages (
	id UUID NOT NULL, 
	session_id UUID NOT NULL, 
	sender_id UUID NOT NULL, 
	content TEXT NOT NULL, 
	is_moderated BOOLEAN NOT NULL, 
	sent_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(session_id) REFERENCES class_sessions (id) ON DELETE CASCADE, 
	FOREIGN KEY(sender_id) REFERENCES profiles (id) ON DELETE CASCADE
)

;


CREATE TABLE lecture_materials (
	id UUID NOT NULL, 
	course_id UUID NOT NULL, 
	session_id UUID, 
	uploaded_by UUID NOT NULL, 
	title VARCHAR(255) NOT NULL, 
	material_type material_type NOT NULL, 
	storage_url TEXT, 
	source_text TEXT, 
	mime_type VARCHAR(120), 
	is_approved_for_ai BOOLEAN NOT NULL, 
	retention_until DATE, 
	created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(course_id) REFERENCES courses (id) ON DELETE CASCADE, 
	FOREIGN KEY(session_id) REFERENCES class_sessions (id) ON DELETE SET NULL, 
	FOREIGN KEY(uploaded_by) REFERENCES profiles (id) ON DELETE RESTRICT
)

;


CREATE TABLE questions (
	id UUID NOT NULL, 
	session_id UUID NOT NULL, 
	created_by UUID NOT NULL, 
	question_type question_type NOT NULL, 
	text TEXT NOT NULL, 
	options JSONB, 
	correct_answer JSONB, 
	published_at TIMESTAMP WITH TIME ZONE, 
	closes_at TIMESTAMP WITH TIME ZONE, 
	points NUMERIC(6, 2) NOT NULL, 
	created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(session_id) REFERENCES class_sessions (id) ON DELETE CASCADE, 
	FOREIGN KEY(created_by) REFERENCES profiles (id) ON DELETE RESTRICT
)

;


CREATE TABLE session_participants (
	id UUID NOT NULL, 
	session_id UUID NOT NULL, 
	student_id UUID NOT NULL, 
	first_join_at TIMESTAMP WITH TIME ZONE, 
	last_leave_at TIMESTAMP WITH TIME ZONE, 
	total_duration_seconds INTEGER NOT NULL, 
	attendance_status attendance_status NOT NULL, 
	is_manually_corrected BOOLEAN NOT NULL, 
	created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	PRIMARY KEY (id), 
	CONSTRAINT uq_session_participant UNIQUE (session_id, student_id), 
	FOREIGN KEY(session_id) REFERENCES class_sessions (id) ON DELETE CASCADE, 
	FOREIGN KEY(student_id) REFERENCES profiles (id) ON DELETE CASCADE
)

;


CREATE TABLE ai_messages (
	id UUID NOT NULL, 
	conversation_id UUID NOT NULL, 
	role ai_message_role NOT NULL, 
	content TEXT NOT NULL, 
	model_name VARCHAR(150), 
	source_citations JSONB, 
	safety_metadata JSONB, 
	created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(conversation_id) REFERENCES ai_conversations (id) ON DELETE CASCADE
)

;


CREATE TABLE attendance_adjustments (
	id UUID NOT NULL, 
	participant_id UUID NOT NULL, 
	adjusted_by UUID NOT NULL, 
	previous_status adjustment_previous_status NOT NULL, 
	new_status adjustment_new_status NOT NULL, 
	previous_duration_seconds INTEGER, 
	new_duration_seconds INTEGER, 
	reason TEXT NOT NULL, 
	created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(participant_id) REFERENCES session_participants (id) ON DELETE CASCADE, 
	FOREIGN KEY(adjusted_by) REFERENCES profiles (id) ON DELETE RESTRICT
)

;


CREATE TABLE responses (
	id UUID NOT NULL, 
	question_id UUID NOT NULL, 
	student_id UUID NOT NULL, 
	answer JSONB NOT NULL, 
	submitted_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	is_correct BOOLEAN, 
	score NUMERIC(6, 2), 
	metadata JSONB, 
	created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	PRIMARY KEY (id), 
	CONSTRAINT uq_question_student_response UNIQUE (question_id, student_id), 
	FOREIGN KEY(question_id) REFERENCES questions (id) ON DELETE CASCADE, 
	FOREIGN KEY(student_id) REFERENCES profiles (id) ON DELETE CASCADE
)

;


CREATE TABLE study_questions (
	id UUID NOT NULL, 
	course_id UUID NOT NULL, 
	material_id UUID, 
	generated_by UUID, 
	question_text TEXT NOT NULL, 
	answer TEXT NOT NULL, 
	difficulty VARCHAR(30) NOT NULL, 
	model_name VARCHAR(150) NOT NULL, 
	prompt_version VARCHAR(50) NOT NULL, 
	review_status study_question_review_status NOT NULL, 
	source_citations JSONB, 
	created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(course_id) REFERENCES courses (id) ON DELETE CASCADE, 
	FOREIGN KEY(material_id) REFERENCES lecture_materials (id) ON DELETE SET NULL, 
	FOREIGN KEY(generated_by) REFERENCES profiles (id) ON DELETE SET NULL
)

;


CREATE TABLE transcripts (
	id UUID NOT NULL, 
	material_id UUID NOT NULL, 
	language VARCHAR(20) NOT NULL, 
	text TEXT NOT NULL, 
	processing_status processing_status NOT NULL, 
	provider VARCHAR(100), 
	error_message TEXT, 
	created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(material_id) REFERENCES lecture_materials (id) ON DELETE CASCADE
)

;


CREATE TABLE lecture_summaries (
	id UUID NOT NULL, 
	material_id UUID NOT NULL, 
	transcript_id UUID, 
	generated_by UUID, 
	summary_text TEXT NOT NULL, 
	model_name VARCHAR(150) NOT NULL, 
	prompt_version VARCHAR(50) NOT NULL, 
	review_status ai_review_status NOT NULL, 
	reviewed_by UUID, 
	reviewed_at TIMESTAMP WITH TIME ZONE, 
	source_citations JSONB, 
	created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(material_id) REFERENCES lecture_materials (id) ON DELETE CASCADE, 
	FOREIGN KEY(transcript_id) REFERENCES transcripts (id) ON DELETE SET NULL, 
	FOREIGN KEY(generated_by) REFERENCES profiles (id) ON DELETE SET NULL, 
	FOREIGN KEY(reviewed_by) REFERENCES profiles (id) ON DELETE SET NULL
)

;
