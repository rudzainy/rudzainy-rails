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
    highlight: ""
  },
  {
    title: "UI/UX Developer",
    subtitle: "Affin Bank",
    location: "Kuala Lumpur, Malaysia",
    start_date: "2021-01-04",
    end_date: "2021-03-31",
    remarks: "",
    category: :employment,
    highlight: "Digitizing SMEs"
  },
  {
    title: "Senior Frontend Engineer",
    subtitle: "Kaodim",
    location: "Kuala Lumpur, Malaysia",
    start_date: "2020-07-01",
    end_date: "2020-08-31",
    remarks: "",
    category: :employment,
    highlight: ""
  },
  {
    title: "UI/UX Designer",
    subtitle: "Rev Asia ",
    location: "Selangor, Malaysia",
    start_date: "2019-06-03",
    end_date: "2020-02-28",
    remarks: "",
    category: :employment,
    highlight: ""
  },
  {
    title: "UI/UX Designer",
    subtitle: "DXC Technology",
    location: "Selangor, Malaysia",
    start_date: "2018-05-01",
    end_date: "2019-05-31",
    remarks: "",
    category: :employment,
    highlight: ""
  },
  {
    title: "IT Manager (acting Chief Technical Officer)",
    subtitle: "Pacific Trustees Berhad",
    location: "Kuala Lumpur, Malaysia",
    start_date: "2017-10-02",
    end_date: "2018-03-30",
    remarks: "",
    category: :employment,
    highlight: ""
  },
  {
    title: "Front End Web Developer / Programming Bootcamp Mentor",
    subtitle: "NEXT Academy ",
    location: "Kuala Lumpur, Malaysia",
    start_date: "2015-10-01",
    end_date: "2017-10-31",
    remarks: "",
    category: :employment,
    highlight: ""
  },
  {
    title: "Lecturer",
    subtitle: "Universiti Tenaga Nasional",
    location: "Selangor, Malaysia",
    start_date: "2012-08-01",
    end_date: "2014-07-31",
    remarks: "",
    category: :employment,
    highlight: ""
  },
  {
    title: "HRA / Business Development Executive",
    subtitle: "Malaysia Maritime Association",
    location: "Selangor & Perak, Malaysia",
    start_date: "2009-12-01",
    end_date: "2012-07-31",
    remarks: "",
    category: :employment,
    highlight: ""
  },
  {
    title: "L1 Technical Helpdesk Specialist",
    subtitle: "Jones Lang LaSalle Technology Service Center",
    location: "Selangor, Malaysia",
    start_date: "2009-09-01",
    end_date: "2009-12-31",
    remarks: "Part time contract term",
    category: :employment,
    highlight: ""
  },
  {
    title: "Web / Graphic Designer",
    subtitle: "Teras Solutions Sdn Bhd",
    location: "Selangor, Malaysia",
    start_date: "2008-08-04",
    end_date: "2009-08-28",
    remarks: "",
    category: :employment,
    highlight: ""
  },
  {
    title: "Web Designer",
    subtitle: "MSC Management Services Sdn Bhd",
    location: "Selangor, Malaysia",
    start_date: "2007-08-01",
    end_date: "2007-12-28",
    remarks: "Practical training",
    category: :employment,
    highlight: ""
  },
  {
    title: "General Factory Worker",
    subtitle: "Asahi Kosai ",
    location: "Selangor, Malaysia",
    start_date: "2005-01-03",
    end_date: "2005-03-31",
    remarks: "",
    category: :employment,
    highlight: ""
  },
  {
    title: "Crew",
    subtitle: "McDonald's (Golden Arches Sdn Bhd)",
    location: "Selangor, Malaysia",
    start_date: "2003-01-01",
    end_date: "2003-03-28",
    remarks: "",
    category: :employment,
    highlight: ""
  },
  {
    title: "Freelance Digital Consultant",
    subtitle: "rudzainy.my (previously rudzainy.com)",
    location: "Global",
    start_date: "2015-09-01",
    end_date: nil,
    remarks: "",
    category: :freelancing,
    highlight: ""
  },
  {
    title: "Founder, Full Stack Developer & Product Designer",
    subtitle: "Gugel.my (Software as a Service)",
    location: "Malaysia",
    start_date: "2023-03-01",
    end_date: nil,
    remarks: "Benched",
    category: :employment,
    highlight: ""
  },
  {
    title: "Founder, Full Stack Developer & Product Designer",
    subtitle: "Hoojah.my (Software as a Service)",
    location: "Malaysia",
    start_date: "2013-09-01",
    end_date: "2021-02-28",
    remarks: "Sunset",
    category: :freelancing,
    highlight: ""
  },
  {
    title: "Stage Manager",
    subtitle: "SudirMANIA (Indie Musical Theatre Production)",
    location: "Selangor, Malaysia",
    start_date: "2018-11-01",
    end_date: "2019-03-29",
    remarks: "",
    category: :freelancing,
    highlight: ""
  },
  {
    title: "Director, Co-Writer & Producer",
    subtitle: "Orang Kasar (Indie Theatre Production)",
    location: "Selangor, Malaysia",
    start_date: "2018-08-01",
    end_date: "2018-10-31",
    remarks: "",
    category: :freelancing,
    highlight: ""
  },
  {
    title: "Bc. (Hons) Information Technology (Multimedia Studies)",
    subtitle: "National University of Malaysia",
    location: "Selangor, Malaysia",
    start_date: "2005-07-01",
    end_date: "2009-08-31",
    remarks: "",
    category: :education,
    highlight: ""
  },
  {
    title: "Full Stack Ruby on Rails Web Development Bootcamp",
    subtitle: "NEXT Academy",
    location: "Kuala Lumpur, Malaysia",
    start_date: "2015-11-02",
    end_date: "2016-01-29",
    remarks: "",
    category: :education,
    highlight: ""
  }
]

events.each do |event_data|
  event = Event.create!(event_data)
  puts "Created event: #{event.title}"
end

puts "Created #{Event.count} events"
