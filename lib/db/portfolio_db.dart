/// Mirrors `lib/db/portfolio_db.json` so hot-reloaded sessions can load the
/// DB immediately even before Flutter Web rebuilds `AssetManifest.json`.
const Map<String, dynamic> kPortfolioSeedDb = {
  "profile": {
    "fullName": "Naing Paing Oo",
    "greeting": "Hello, I'm",
    "roleTitle": "A Flutter Developer",
    "storybookSubtitle":
        "Crafting Cross-Platform Worlds across Mobile, Web & Desktop",
    "bio":
        "A Computer Science graduate (B.C.Sc. with 5 Distinctions) and Flutter Developer crafting high-performance Android, iOS, Web, and Desktop applications with clean architecture and expressive UI/UX.",
    "availabilityText": "Available for Flutter & Cross-Platform Opportunities",
    "isAvailable": true,
    "avatarImage": "assets/my_passport.png",
    "resumeUrl": "https://www.linkedin.com/in/naingpaingoo/",
    "email": "naingpaingoo@gmail.com",
    "phone": "+959790663667",
    "location": "Myanmar",
    "footerText": "Made by Min Naing Paing Oo with Flutter",
    "stats": [
      {"value": "4+", "label": "Target Platforms"},
      {"value": "9+", "label": "Shipped Projects"},
      {"value": "5", "label": "Distinctions (B.C.Sc.)"}
    ],
    "snsLinks": {
      "github": "https://www.github.com/minnaingpaingoo",
      "linkedin": "https://www.linkedin.com/in/naingpaingoo/",
      "twitter": "https://twitter.com/naingpaingoo",
      "facebook": "https://www.facebook.com/minnaingpaingoo",
      "instagram": "https://www.instagram.com/minnaingpaingoo/",
      "telegram": "https://t.me/minnaingpaingoo"
    }
  },
  "experiences": [
    {
      "id": "exp_1",
      "role": "Junior Flutter Developer",
      "company": "ITVisionHub",
      "period": "August 2024 – July 2025",
      "isCurrent": true,
      "description":
          "Developing and maintaining cross-platform production Flutter applications with modern UI/UX and cloud integrations.",
      "highlights": [
        "Building responsive cross-platform Flutter apps for Android, iOS, and Web.",
        "Collaborating with design and backend teams to deliver production features.",
        "Integrating RESTful APIs, Firebase services, and clean state management."
      ],
      "order": 1
    },
    {
      "id": "exp_2",
      "role": "Junior Developer Intern",
      "company": "Myanmar DCR Co., Ltd.",
      "period": "May 2024 – July 2024",
      "isCurrent": false,
      "description":
          "Completed intensive software engineering internship focused on enterprise development workflows and quality assurance.",
      "highlights": [
        "Contributed to full-stack application modules and bug resolution.",
        "Practiced agile teamwork, code reviews, and structured technical documentation."
      ],
      "order": 2
    },
    {
      "id": "exp_3",
      "role": "Development Team Member",
      "company":
          "Collaboration of Kyaik Htee Yoe Pagoda Gopaka & University of Computer Studies, Thaton",
      "period": "November 2023 – December 2023",
      "isCurrent": false,
      "description":
          "Co-developed the official Kyaik Htee Yoe Pagoda web portal to serve pilgrims and international visitors.",
      "highlights": [
        "Built and launched https://www.kyaikhteeyoepagoda.org with historical guides and travel resources.",
        "Designed responsive layouts for smooth browsing across mobile and desktop devices."
      ],
      "order": 3
    }
  ],
  "educations": [
    {
      "id": "edu_1",
      "degree": "Bachelor of Computer Science (B.C.Sc.)",
      "institution": "University of Computer Studies, Thaton",
      "period": "December 2017 – January 2025",
      "honors":
          "Passed with 5 Distinctions and Qualified to Proceed to M.C.Sc.",
      "coursework": [
        "Mobile App Development",
        "Web Application Development",
        "Database Management Systems",
        "Software Engineering"
      ],
      "order": 1
    }
  ],
  "platforms": [
    {
      "id": "plat_1",
      "img": "assets/android_icon.png",
      "title": "Android Development",
      "subtitle":
          "High-performance native & cross-platform Android applications with Flutter, Dart, Java & Kotlin.",
      "order": 1
    },
    {
      "id": "plat_2",
      "img": "assets/web.png",
      "title": "Web Development",
      "subtitle":
          "Responsive modern web applications & portals powered by Flutter Web, HTML5/CSS3, JS, PHP & ASP.Net.",
      "order": 2
    },
    {
      "id": "plat_3",
      "img": "assets/ios.png",
      "title": "iOS Development",
      "subtitle":
          "Fluid, Cupertino-compliant iOS mobile experiences crafted from a unified Flutter codebase.",
      "order": 3
    },
    {
      "id": "plat_4",
      "img": "assets/desktop.png",
      "title": "Desktop Development",
      "subtitle":
          "Multi-window Windows, macOS, and Linux desktop utilities with adaptive layouts.",
      "order": 4
    }
  ],
  "skills": [
    {
      "id": "skill_1",
      "img": "assets/flutter.png",
      "title": "Flutter",
      "category": "Mobile & Core",
      "order": 1
    },
    {
      "id": "skill_2",
      "img": "assets/dart.png",
      "title": "Dart",
      "category": "Mobile & Core",
      "order": 2
    },
    {
      "id": "skill_3",
      "img": "assets/kotlin.jpeg",
      "title": "Kotlin",
      "category": "Mobile & Core",
      "order": 3
    },
    {
      "id": "skill_4",
      "img": "assets/java.png",
      "title": "Java",
      "category": "Mobile & Core",
      "order": 4
    },
    {
      "id": "skill_5",
      "img": "assets/html5.png",
      "title": "HTML5",
      "category": "Web & Frontend",
      "order": 5
    },
    {
      "id": "skill_6",
      "img": "assets/css3.png",
      "title": "CSS3",
      "category": "Web & Frontend",
      "order": 6
    },
    {
      "id": "skill_7",
      "img": "assets/javascript.png",
      "title": "JavaScript",
      "category": "Web & Frontend",
      "order": 7
    },
    {
      "id": "skill_8",
      "img": "assets/bootstrap.png",
      "title": "Bootstrap",
      "category": "Web & Frontend",
      "order": 8
    },
    {
      "id": "skill_9",
      "img": "assets/php.png",
      "title": "PHP",
      "category": "Backend & Database",
      "order": 9
    },
    {
      "id": "skill_10",
      "img": "assets/asp_net.png",
      "title": "ASP.Net",
      "category": "Backend & Database",
      "order": 10
    },
    {
      "id": "skill_11",
      "img": "assets/c++.png",
      "title": "C++",
      "category": "Backend & Database",
      "order": 11
    },
    {
      "id": "skill_12",
      "img": "assets/mysql.png",
      "title": "MySQL",
      "category": "Backend & Database",
      "order": 12
    },
    {
      "id": "skill_13",
      "img": "assets/firebase.png",
      "title": "Firebase",
      "category": "Backend & Database",
      "order": 13
    },
    {
      "id": "skill_14",
      "img": "assets/figma.png",
      "title": "Figma",
      "category": "Design & DevOps",
      "order": 14
    },
    {
      "id": "skill_15",
      "img": "assets/postman.png",
      "title": "Postman",
      "category": "Design & DevOps",
      "order": 15
    },
    {
      "id": "skill_16",
      "img": "assets/github.png",
      "title": "GitHub",
      "category": "Design & DevOps",
      "order": 16
    },
    {
      "id": "skill_17",
      "img": "assets/docker.png",
      "title": "Docker",
      "category": "Design & DevOps",
      "order": 17
    }
  ],
  "projects": [
    {
      "id": "work_1",
      "image": "assets/projects/ucstt_logo.png",
      "title": "UCSTT Voting App",
      "subtitle":
          "A real-time digital voting app designed for UCSTT King & Queen selection events with secure Firestore tallying.",
      "detail":
          "A digital voting app designed for UCSTT King & Queen selection events. The app allows users to vote for their favorite participants in a secure, transparent, and user-friendly way. Built with Flutter and Firestore, it ensures real-time vote updates, dynamic participant listings, and a seamless user experience.",
      "projectType": "work",
      "category": "Mobile App",
      "techStack": ["Flutter", "Dart", "Firebase", "Cloud Firestore"],
      "githubLink": "https://github.com/minnaingpaingoo/ucstt_voting",
      "order": 1
    },
    {
      "id": "work_2",
      "image": "assets/projects/dfd.png",
      "title": "Daily Fair Deal App",
      "subtitle":
          "A local commerce platform connecting shoppers with nearby stores for daily deals on groceries and essentials.",
      "detail":
          "Daily Fair Deal App is a convenient platform that connects users with local shops, offering the best daily deals on groceries, household essentials, and more. With an easy-to-use interface, users can browse products, place orders, and enjoy hassle-free doorstep delivery – making everyday shopping smarter and more affordable.",
      "projectType": "work",
      "category": "Mobile App",
      "techStack": ["Flutter", "Dart", "REST API", "Mobile Commerce"],
      "githubLink": "https://github.com/minnaingpaingoo/daily_fair_deal",
      "order": 2
    },
    {
      "id": "work_3",
      "image": "assets/projects/khy_pagoda.png",
      "title": "Kyaik Htee Yoe Pagoda Web App",
      "subtitle":
          "Official heritage and travel portal developed in collaboration with the University of Computer Studies, Thaton.",
      "detail":
          "Worked with the University of Computer Studies, Thaton to develop the official Kyaik Htee Yoe Pagoda website using WordPress (Content Management System). The platform provides visitors with essential information about the pagoda, its history, and travel guides. With a responsive design and interactive features, it offers a seamless experience for pilgrims and tourists.",
      "projectType": "work",
      "category": "Web Platform",
      "techStack": ["WordPress", "PHP", "HTML5", "CSS3", "MySQL"],
      "webLink": "https://www.kyaikhteeyoepagoda.org",
      "order": 3
    },
    {
      "id": "work_4",
      "image": "assets/projects/trip_booking_platform.png",
      "title": "Trip Booking Platform Web App",
      "subtitle":
          "Full-stack travel reservation platform integrating responsive Bootstrap UI with a PHP & MySQL booking engine.",
      "detail":
          "Collaborated in developing a dynamic trip booking system that seamlessly integrates the front-end (HTML, CSS, JavaScript, Bootstrap) with the back-end (PHP, XAMPP Database). The platform allows users to easily search, book, and manage trips, offering a smooth and interactive user experience.",
      "projectType": "work",
      "category": "Web Platform",
      "techStack": [
        "HTML5",
        "CSS3",
        "JavaScript",
        "Bootstrap",
        "PHP",
        "MySQL"
      ],
      "githubLink": "https://github.com/minnaingpaingoo/trip-booking-platform",
      "order": 4
    },
    {
      "id": "work_5",
      "image": "assets/projects/adsnap.png",
      "title": "AdSnap Web App",
      "subtitle":
          "E-commerce & advertisement management platform enabling teams to create, manage, and publish digital campaigns.",
      "detail":
          "Collaborated with a team to design and implement an e-commerce website (AdSnap, Advertisement Management System) using HTML, CSS, JavaScript and Bootstrap for the front-end and PHP with XAMPP Database for the back-end. The platform allows users to create, manage, and publish advertisements, offering a seamless and efficient advertising experience.",
      "projectType": "work",
      "category": "Web Platform",
      "techStack": ["PHP", "MySQL", "JavaScript", "Bootstrap", "HTML5/CSS3"],
      "githubLink": "https://github.com/minnaingpaingoo/adsnap.com",
      "order": 5
    },
    {
      "id": "work_6",
      "image": "assets/projects/library.jpg",
      "title": "Library Management System Web App",
      "subtitle":
          "University library circulation and catalog portal engineered with ASP.Net and ADO.Net database integration.",
      "detail":
          "A web application for University Library using ASP.Net and ADO.Net for database integration. The platform allows users to search, borrow, and return books, manage user accounts, and track library activities efficiently. With a user-friendly interface and secure database integration, it ensures a seamless and organized library experience.",
      "projectType": "work",
      "category": "Web Platform",
      "techStack": ["ASP.Net", "ADO.Net", "C#", "SQL Server", "Web Forms"],
      "githubLink":
          "https://github.com/minnaingpaingoo/Library-Management-System",
      "order": 6
    },
    {
      "id": "hobby_1",
      "image": "assets/projects/brew_crew.png",
      "title": "Brew Crew Coffee Shop App",
      "subtitle":
          "Your ultimate coffee companion to customize handcrafted beverages, manage preferences, and place orders.",
      "detail":
          "Brew Crew Coffee Shop App is your ultimate coffee companion, designed to bring convenience and flavor right to your fingertips. Browse our rich menu of handcrafted beverages, fresh pastries, and signature blends. Easily place orders, customize your drinks, and enjoy seamless payment options.",
      "projectType": "hobby",
      "category": "Mobile App",
      "techStack": ["Flutter", "Dart", "Firebase Auth", "Cloud Firestore"],
      "githubLink": "https://github.com/minnaingpaingoo/brew_crew",
      "order": 7
    },
    {
      "id": "hobby_2",
      "image": "assets/projects/delivery_app.png",
      "title": "Food Delivery App",
      "subtitle":
          "A seamless food ordering application connecting hungry diners with local restaurant menus and live tracking.",
      "detail":
          "A seamless food ordering app designed to connect users with their favorite restaurants. It allows users to explore menus, customize orders, and track deliveries in real-time. With an intuitive interface and secure payment options, the app ensures a fast, convenient, and satisfying dining experience.",
      "projectType": "hobby",
      "category": "Mobile App",
      "techStack": ["Flutter", "Dart", "UI/UX", "State Management"],
      "githubLink": "https://github.com/minnaingpaingoo/food_delivery",
      "order": 8
    },
    {
      "id": "hobby_3",
      "image": "assets/projects/world_time.png",
      "title": "World Time App",
      "subtitle":
          "Stay connected across global time zones with instant city lookups and dynamic day/night visual themes.",
      "detail":
          "Stay connected across the globe with the World Time App. Easily check the current time in multiple cities, manage time zone differences, and plan your meetings efficiently. With a user-friendly interface and accurate time updates, it's the perfect tool for global travelers and remote workers.",
      "projectType": "hobby",
      "category": "Mobile App",
      "techStack": ["Flutter", "Dart", "REST API", "WorldTimeAPI"],
      "githubLink":
          "https://github.com/minnaingpaingoo/Flutter-Lesson/tree/main/world_time1",
      "order": 9
    }
  ]
};
