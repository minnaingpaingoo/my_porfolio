class ProjectUtils{
  final String image;
  final String title;
  final String subtitle;
  final String? androidLink;
  final String? iosLink;
  final String? webLink;
  final String? githubLink;

  ProjectUtils({
    required this.image,
    required this.title,
    required this.subtitle,
    this.androidLink,
    this.iosLink,
    this.webLink,
    this.githubLink,
  });
}

// Hobby Projects
List<ProjectUtils> hobbyProjectUtils = [
  ProjectUtils(
    image: "assets/projects/1.png",
    title: "Project 1",
    subtitle: "This is a coffee shop application",
    githubLink: "",
  ),
  ProjectUtils(
    image: "assets/projects/2.png",
    title: "Project 2",
    subtitle: "Project 2 subtitle",
    githubLink: "",
  ),
  ProjectUtils(
    image: "assets/projects/3.png",
    title: "Project 3",
    subtitle: "Project 3 subtitle",
    githubLink: "",
  ),
  ProjectUtils(
    image: "assets/projects/4.png",
    title: "Project 4",
    subtitle: "Project 4 subtitle",
    githubLink: "",
  )
];

List<ProjectUtils> workProjectUtils=[
  ProjectUtils(
    image: "assets/projects/5.png",
    title: "Project 5",
    subtitle: "Project 5 subtitle",
    githubLink: "",
  ),
  ProjectUtils(
    image: "assets/projects/6.png",
    title: "Project 6",
    subtitle: "Project 6 subtitle",
    githubLink: "",
  ),
  ProjectUtils(
    image: "assets/projects/7.png",
    title: "Project 7",
    subtitle: "Project 7 subtitle",
    githubLink: "",
  ),
  ProjectUtils(
    image: "assets/projects/8.png",
    title: "Project 8",
    subtitle: "Project 8 subtitle",
    githubLink: "",
  )
];