# Get existing events content before clearing
puts "Retrieving existing event content..."
existing_events = {}
Event.all.each do |event|
  existing_events[event.title] = event.content.to_s if event.content.present?
end

# Clear existing events
puts "Clearing existing events..."
Event.destroy_all

# Create events
puts "Creating events..."

events = [
  {
    title: "Platform Designer",
    subtitle: "Ace Resource Advisory Services",
    location: "Kuala Lumpur, Malaysia",
    start_date: "2022-08-01",
    end_date: "2023-12-29",
    remarks: "Term Hire",
    category: :employment,
    highlight: "",
    content: "- Web & mobile app for palm oil seed production.\n- Web & mobile app for R&D activities.\n- Left early from my 2-year contract to find a more flexible working environment."
  },
  {
    title: "UI/UX Developer",
    subtitle: "Affin Bank",
    location: "Kuala Lumpur, Malaysia",
    start_date: "2021-01-04",
    end_date: "2021-03-31",
    remarks: "",
    category: :employment,
    highlight: "Digitizing SMEs",
    content: "Plan and manage Affin Group web consolidation project.\n- Managed a junior UX designer who was handling multiple projects.\n- Planned and executed UX workshops for all stakeholder levels for the digitalisation of Affin Bank's services.\n- Participate and provide feedback for vendor's solution presentations.\n- Decided not to proceed after probation due to work culture mismatch."
  },
  {
    title: "Senior Frontend Engineer",
    subtitle: "Kaodim",
    location: "Kuala Lumpur, Malaysia",
    start_date: "2020-07-01",
    end_date: "2020-08-31",
    remarks: "",
    category: :employment,
    highlight: "",
    content: "Maintain and build new features in the existing system.\n- Technology stack: Ruby on Rails, ReactJS, SCSS.\n- Decided to leave to take care of my then sick father."
  },
  {
    title: "UI/UX Designer",
    subtitle: "Rev Asia ",
    location: "Selangor, Malaysia",
    start_date: "2019-06-03",
    end_date: "2020-02-28",
    remarks: "",
    category: :employment,
    highlight: "",
    content: "Redesign says.com from the ground up.\n- UX research on how to optimise reader's and writer's experiences for news portals.\n- Revamp says.com UI.\n- Research on optimising workflow for the tech team across multiple news portals.\n- Left after being called back by the UI/UX team in DXC Technology. Unfortunately the pandemic situation then has caused all new hirings to be frozen."
  },
  {
    title: "UI/UX Designer",
    subtitle: "DXC Technology",
    location: "Selangor, Malaysia",
    start_date: "2018-05-01",
    end_date: "2019-05-31",
    remarks: "",
    category: :employment,
    highlight: "",
    content: "- Reports directly to the Director of Engineering / Automation.\n- Design UI/UX for SAAS-like applications based on user stories provided by BAs.\n- Design and build concepts for marketing pages.\n- Get feedback from stakeholders from different regions of the world.\n- Left due to internal politics resulting in the resignation of my reporting manager and a department-wide layovers."
  },
  {
    title: "IT Manager (acting Chief Technical Officer)",
    subtitle: "Pacific Trustees Berhad",
    location: "Kuala Lumpur, Malaysia",
    start_date: "2017-10-02",
    end_date: "2018-03-30",
    remarks: "",
    category: :employment,
    highlight: "",
    content: "Temporary position to help a friend manage a job listing app that I built for his company.\n- Manage the IT department for the group of companies which includes one senior and one junior IT executive.\n- Managed business disaster recovery plan.\n- Liaise with service providers and present solutions directly to the Board of Directors.\n- Successfully planned and executed a disaster recovery drill.\n- Worked with other departments on IT related matters."
  },
  {
    title: "Front End Web Developer / Programming Bootcamp Mentor",
    subtitle: "NEXT Academy ",
    location: "Kuala Lumpur, Malaysia",
    start_date: "2015-10-01",
    end_date: "2017-10-31",
    remarks: "",
    category: :employment,
    highlight: "",
    content: "Mentor:\n- Mentor students for a 9-week bootcamp.\n- Topics covered in the boot camp includes Ruby, ActiveRecord, Basic HTML & CSS, Basic JavaScript, Sinatra framework and Ruby on Rails framework.\n- Have mentored a total of 14 intakes.\n- Main tasks was to assist students with their assignments throughout the 9-weeks bootcamp as well as giving lectures, doing class revisions, reviewing student assessments and other classroom related tasks.\n- Assist other departments on company activities such as live events and other marketing programmes.\nFront End Web Developer\n- Develop and maintain in-house web applications for Next Academy.\n- Daily tasks include building new features, review pull requests and bug fixes.\n- Take away from the experience: Working in a team to build and maintain a Ruby on Rails apps, ReactJS framework, building and working with various APIs."
  },
  {
    title: "Lecturer",
    subtitle: "Universiti Tenaga Nasional",
    location: "Selangor, Malaysia",
    start_date: "2012-08-01",
    end_date: "2014-07-31",
    remarks: "",
    category: :employment,
    highlight: "",
    content: "- Lecturing for diploma and foundation classes.\n- Course subjects include Introduction to C Programming, Web Programming, Introduction to Computer, Basic Computing Skills, and Multimedia subjects.\n- Develop a new diploma programme in multimedia for accreditation submission.\n- Supervise and coordinate student activities as well as university programs."
  },
  {
    title: "HRA / Business Development Executive",
    subtitle: "Malaysia Maritime Association",
    location: "Selangor & Perak, Malaysia",
    start_date: "2009-12-01",
    end_date: "2012-07-31",
    remarks: "",
    category: :employment,
    highlight: "",
    content: "- Worked in a project management team to build a maritime academy in Seri Manjung, Perak and in Rawang, Selangor from the ground up.\n- Coordinate with property developers and the Fire and Rescue Department (Bomba) to secure premises for leasing and obtain safety certifications necessary for operating a learning centre with accommodation.\n- Assisted in the development of syllabus for a basic seamanship programme.\n- Liaise with officials from the Marine Department of Malaysia for accreditations, reporting and other official businesses.\n- Manage day-to-day operations of the academy.\n- Plan, supervise and coordinate student activities."
  },
  {
    title: "L1 Technical Helpdesk Specialist",
    subtitle: "Jones Lang LaSalle Technology Service Center",
    location: "Selangor, Malaysia",
    start_date: "2009-09-01",
    end_date: "2009-12-31",
    remarks: "Part time contract term",
    category: :employment,
    highlight: "",
    content: "- Main role was to be the first point of contact for users experiencing technical issues, including software, hardware, network, or system-related problems.\n- Supported mainly India and Australia users, as well as users from Singapore, New Zealand and Hong Kong.\n- Diagnose and resolve technical issues which involved guiding users through step-by-step solutions over the phone, using remote desktop tools to access their systems, or escalating issues to higher-level support teams when necessary.\n- Document all technical support interactions, including the nature of the issue, troubleshooting steps taken, and resolutions provided..\n- Resigned from the role to join a project management opportunity."
  },
  {
    title: "Web / Graphic Designer",
    subtitle: "Teras Solutions Sdn Bhd",
    location: "Selangor, Malaysia",
    start_date: "2008-08-04",
    end_date: "2009-08-28",
    remarks: "",
    category: :employment,
    highlight: "",
    content: "- Rebranding the company's corporate image.\n- Involved in most of the company's web portal projects as the lead designer.\n- Involved in conducting and facilitating training on web design using Joomla! 1.5."
  },
  {
    title: "Web Designer",
    subtitle: "MSC Management Services Sdn Bhd",
    location: "Selangor, Malaysia",
    start_date: "2007-08-01",
    end_date: "2007-12-28",
    remarks: "Practical training",
    category: :employment,
    highlight: "",
    content: "Involved exclusively in the design phase for the development of Seri Malaysia Hotels web portal. The site has since been revamped."
  },
  {
    title: "General Factory Worker",
    subtitle: "Asahi Kosai ",
    location: "Selangor, Malaysia",
    start_date: "2005-01-03",
    end_date: "2005-03-31",
    remarks: "",
    category: :employment,
    highlight: "",
    content: "Worked part time at a factory while waiting for my STPM result.\nKey takeaway: Learned the principle of Kaizen."
  },
  {
    title: "Crew",
    subtitle: "McDonald's (Golden Arches Sdn Bhd)",
    location: "Selangor, Malaysia",
    start_date: "2003-01-01",
    end_date: "2003-03-28",
    remarks: "",
    category: :employment,
    highlight: "",
    content: "Worked part time as floor and kitchen crew while waiting for SPM my result.\nKey takeaway: \"Clean as you go\"."
  },
  {
    title: "Freelance Digital Consultant",
    subtitle: "rudzainy.my (previously rudzainy.com)",
    location: "Global",
    start_date: "2015-09-01",
    end_date: nil,
    remarks: "",
    category: :freelancing,
    highlight: "",
    content: "Providing a comprehensive range of services tailored to meet the diverse needs of clients across various industries.\n- Services spans digital marketing strategies, multimedia content creation, graphic design, video production, as well as website and web application development."
  },
  {
    title: "Founder, Full Stack Developer & Product Designer",
    subtitle: "Gugel.my (Software as a Service)",
    location: "Malaysia",
    start_date: "2023-03-01",
    end_date: nil,
    remarks: "Benched",
    category: :employment,
    highlight: "",
    content: "Plan, design and build a link management app.\n- Tech stack: Ruby on Rails 7, Bootstrap 5.\n- Project: https://www.gugel.my"
  },
  {
    title: "Founder, Full Stack Developer & Product Designer",
    subtitle: "Hoojah.my (Software as a Service)",
    location: "Malaysia",
    start_date: "2013-09-01",
    end_date: "2021-02-28",
    remarks: "Sunset",
    category: :freelancing,
    highlight: "",
    content: "Plan, design and build a debating app.\n- Tech stack: Ruby on Rails 6, ReactJS, Bootstrap 4.\n- The project has been archived.\n- Writeup: https://www.behance.net/gallery/175206951/Hoojah"
  },
  {
    title: "Stage Manager",
    subtitle: "SudirMANIA (Indie Musical Theatre Production)",
    location: "Selangor, Malaysia",
    start_date: "2018-11-01",
    end_date: "2019-03-29",
    remarks: "",
    category: :freelancing,
    highlight: "",
    content: "Responsible for ensuring that all elements of the production come together seamlessly for the show.\n- Worked closely with the director, designers, and production team during pre-production planning stage to understand the vision for the show and assist in creating a production schedule.\n- Scheduling and running rehearsals, ensuring actors are on time and prepared, coordinating with the director to facilitate the creative process, and keeping detailed notes on blocking, cues, and technical requirements.\n- Served as a central point of communication between all members of the production team, including designers, crew, and performers.\n- Keeping accurate records of all aspects of the production, including rehearsal schedules, blocking diagrams, and technical cue sheets.\n- Resigned from position mid-production due to constraints during the pandemic."
  },
  {
    title: "Director, Co-Writer & Producer",
    subtitle: "Orang Kasar (Indie Theatre Production)",
    location: "Selangor, Malaysia",
    start_date: "2018-08-01",
    end_date: "2018-10-31",
    remarks: "",
    category: :freelancing,
    highlight: "",
    content: "Directed, co-write and produced an indie theatre play for directing class at Revolution Stage.\n- \"Orang Kasar\" is an adaptation of a play written by Anton Checkov called \"The Bear\".\n- The production ran for 5 days with a total of 7 shows.\n- Directed 2 main cast and 3 supporting cast members.\n- Involved in the end-to-end production process."
  },
  {
    title: "Bc. (Hons) Information Technology (Multimedia Studies)",
    subtitle: "National University of Malaysia",
    location: "Selangor, Malaysia",
    start_date: "2005-07-01",
    end_date: "2009-08-31",
    remarks: "",
    category: :education,
    highlight: "",
    content: "Bachelor's degree in Information Technology with a focus on Multimedia Studies."
  },
  {
    title: "Full Stack Ruby on Rails Web Development Bootcamp",
    subtitle: "NEXT Academy",
    location: "Kuala Lumpur, Malaysia",
    start_date: "2015-11-02",
    end_date: "2016-01-29",
    remarks: "",
    category: :education,
    highlight: "",
    content: "Intensive 9-week bootcamp focused on full-stack web development using Ruby on Rails."
  }
]

events.each do |event_data|
  # Add content from existing events if available
  if existing_events[event_data[:title]].present?
    event_data[:content] = existing_events[event_data[:title]]
  elsif !event_data[:content].present?
    # Generate placeholder content if no existing content and none provided
    event_data[:content] = "Details about #{event_data[:title]} at #{event_data[:subtitle]} in #{event_data[:location]}."
  end
  
  event = Event.create!(event_data)
  puts "Created event: #{event.title}"
end

puts "Created #{Event.count} events"
