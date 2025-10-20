-- Create EMR database user
CREATE USER emr_user WITH PASSWORD 'emr-password';

-- Create EMR database
CREATE DATABASE emr_db;

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE emr_db TO emr_user;

-- Change database owner
ALTER DATABASE emr_db OWNER TO emr_user;

-- Connect to the emr_db database to create tables
\c emr_db

-- Create doctors table
CREATE TABLE IF NOT EXISTS doctors (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    specialty VARCHAR(255) NOT NULL,
    department VARCHAR(255),
    email VARCHAR(255),
    phone VARCHAR(50),
    availability VARCHAR(100),
    booked BIT(1) DEFAULT B'0',
    appointment_date DATE,
    appointment_time TIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Grant table privileges to emr_user
GRANT ALL PRIVILEGES ON TABLE doctors TO emr_user;
GRANT USAGE, SELECT ON SEQUENCE doctors_id_seq TO emr_user;

-- Insert sample doctors data
INSERT INTO doctors (name, specialty, department, email, phone, availability, booked) VALUES
    ('Dr. John Smith', 'Cardiology', 'Cardiovascular', 'john.smith@hospital.com', '555-0101', 'Mon-Fri 9AM-5PM', B'0'),
    ('Dr. Sarah Johnson', 'Cardiology', 'Cardiovascular', 'sarah.johnson@hospital.com', '555-0102', 'Mon-Fri 8AM-4PM', B'0'),
    ('Dr. Michael Chen', 'Neurology', 'Neuroscience', 'michael.chen@hospital.com', '555-0103', 'Tue-Sat 10AM-6PM', B'0'),
    ('Dr. Emily Williams', 'Pediatrics', 'Children Health', 'emily.williams@hospital.com', '555-0104', 'Mon-Fri 8AM-3PM', B'0'),
    ('Dr. David Brown', 'Orthopedics', 'Musculoskeletal', 'david.brown@hospital.com', '555-0105', 'Mon-Thu 9AM-5PM', B'0'),
    ('Dr. Lisa Anderson', 'Dermatology', 'Skin Care', 'lisa.anderson@hospital.com', '555-0106', 'Wed-Fri 10AM-4PM', B'0'),
    ('Dr. Robert Garcia', 'Oncology', 'Cancer Treatment', 'robert.garcia@hospital.com', '555-0107', 'Mon-Fri 8AM-6PM', B'0'),
    ('Dr. Jennifer Martinez', 'Psychiatry', 'Mental Health', 'jennifer.martinez@hospital.com', '555-0108', 'Mon-Sat 9AM-5PM', B'0'),
    ('Dr. James Wilson', 'Radiology', 'Imaging', 'james.wilson@hospital.com', '555-0109', 'Mon-Fri 7AM-3PM', B'0'),
    ('Dr. Maria Rodriguez', 'Endocrinology', 'Hormone Health', 'maria.rodriguez@hospital.com', '555-0110', 'Tue-Fri 9AM-4PM', B'0');

-- Create index for better search performance
CREATE INDEX idx_doctors_name ON doctors(name);
CREATE INDEX idx_doctors_specialty ON doctors(specialty);
CREATE INDEX idx_doctors_booked ON doctors(booked);

-- Create trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_doctors_updated_at BEFORE UPDATE
    ON doctors FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

