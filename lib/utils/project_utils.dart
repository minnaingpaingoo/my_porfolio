class ProjectUtils{
  final String image;
  final String title;
  final String subtitle;
  final String detail;
  final String? androidLink;
  final String? iosLink;
  final String? webLink;
  final String? githubLink;

  ProjectUtils({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.detail,
    this.androidLink,
    this.iosLink,
    this.webLink,
    this.githubLink,
  });
}

// Hobby Projects
List<ProjectUtils> hobbyProjectUtils = [
  ProjectUtils(
    image: "assets/projects/brew_crew.png",
    title: "Brew Crew Coffee Shop App",
    subtitle: "Brew Crew Coffee Shop App is your ultimate coffee companion, designed to bring convenience and flavor right to your fingertips....",
    detail: "Brew Crew Coffee Shop App is your ultimate coffee companion, designed to bring convenience and flavor right to your fingertips. Browse our rich menu of handcrafted beverages, fresh pastries, and signature blends. Easily place orders, customize your drinks, and enjoy seamless payment options.",
    githubLink: "https://github.com/minnaingpaingoo/brew_crew",
  ),
  ProjectUtils(
    image: "assets/projects/delivery_app.png",
    title: "Food Delivery App",
    subtitle: "A seamless food ordering app designed to connect users with their favorite restaurants. It allows users to explore menus, customize orders, ...",
    detail:"A seamless food ordering app designed to connect users with their favorite restaurants. It allows users to explore menus, customize orders, and track deliveries in real-time. With an intuitive interface and secure payment options, the app ensures a fast, convenient, and satisfying dining experience.",
    githubLink: "https://github.com/minnaingpaingoo/food_delivery",
  ),
  ProjectUtils(
    image: "assets/projects/world_time.png",
    title: "World Time App",
    subtitle: "Stay connected across the globe with the World Time App. Easily check the current time in multiple cities, manage time zone differences, and ...",
    detail: "Stay connected across the globe with the World Time App. Easily check the current time in multiple cities, manage time zone differences, and plan your meetings efficiently. With a user-friendly interface and accurate time updates, it's the perfect tool for global travelers and remote workers.",
    githubLink: "https://github.com/minnaingpaingoo/Flutter-Lesson/tree/main/world_time1",
  ),
];

List<ProjectUtils> workProjectUtils=[
  ProjectUtils(
    image: "assets/projects/ucstt_logo.png",
    title: "UCSTT Voting App",
    subtitle: "A digital voting app designed for UCSTT King & Queen selection events. The app allows users to vote for their favorite participants in a secure, ...",
    detail: "A digital voting app designed for UCSTT King & Queen selection events. The app allows users to vote for their favorite participants in a secure, transparent, and user-friendly way. Built with Flutter and Firestore, it ensures real-time vote updates, dynamic participant listings, and seamless user experience.",
    githubLink: "https://github.com/minnaingpaingoo/ucstt_voting",
  ),
  ProjectUtils(
    image: "assets/projects/dfd.png",
    title: "Daily Fair Deal App",
    subtitle: "Daily Fair Deal App is a convenient platform that connects users with local shops, offering the best daily deals on groceries, household essentials, and more. ...",
    detail: "Daily Fair Deal App is a convenient platform that connects users with local shops, offering the best daily deals on groceries, household essentials, and more. With an easy-to-use interface, users can browse products, place orders, and enjoy hassle-free doorstep delivery – making everyday shopping smarter and more affordable.",
    githubLink: "https://github.com/minnaingpaingoo/daily_fair_deal",
  ),
  ProjectUtils(
    image: "assets/projects/khy_pagoda.png",
    title: "Kyaik Htee Yoe Pagoda Web App",
    subtitle: "Worked with the University of Computer Studies, Thaton to develop the official Kyaik Htee Yoe Pagoda website ...",
    detail: "Worked with the University of Computer Studies, Thaton to develop the official Kyaik Htee Yoe Pagoda website using with Wordpress (Content Management System). The platform provides visitors with essential information about the pagoda, its history, and travel guides. With a responsive design and interactive features, it offers a seamless experience for pilgrims and tourists.",
    webLink: "https://www.kyaikhteeyoepagoda.org",
  ),
  ProjectUtils(
    image: "assets/projects/trip_booking_platform.png",
    title: "Trip Booking Platform Web App",
    subtitle: "Collaborated in developing a dynamic trip booking system that seamlessly integrates the front-end (HTML, CSS, JavaScript, Bootstrap) with the back-end (PHP, XAMPP Database). ...",
    detail: "Collaborated in developing a dynamic trip booking system that seamlessly integrates the front-end (HTML, CSS, JavaScript, Bootstrap) with the back-end (PHP, XAMPP Database). The platform allows users to easily search, book, and manage trips, offering a smooth and interactive user experience.",
    githubLink: "https://github.com/minnaingpaingoo/trip-booking-platform",
  ),
  ProjectUtils(
    image: "assets/projects/adsnap.png",
    title: "AdSnap Web App",
    subtitle: "Collaborated with a team to design and implement an e-commerce website (AdSnap, Advertisement Management System) using HTML, CSS, JavaScript and Bootstrap for the front-end and ...",
    detail: "Collaborated with a team to design and implement an e-commerce website (AdSnap, Advertisement Management System) using HTML, CSS, JavaScript and Bootstrap for the front-end and PHP with XAMPP Database for the back-end. The platform allows users to create, manage, and publish advertisements, offering a seamless and efficient advertising experience.",
    githubLink: "https://github.com/minnaingpaingoo/adsnap.com",
  ),
  ProjectUtils(
    image: "assets/projects/library.jpg",
    title: "Library Management System Web App",
    subtitle: "A web application for University Library using with ASP.Net and ADO.Net for database integration. ...",
    detail: "A web application for University Library using with ASP.Net and ADO.Net for database integration. The platform allows users to search, borrow, and return books, manage user accounts, and track library activities efficiently. With a user-friendly interface and secure database integration, it ensures a seamless and organized library experience.",
    githubLink: "https://github.com/minnaingpaingoo/Library-Management-System",
  ),
];