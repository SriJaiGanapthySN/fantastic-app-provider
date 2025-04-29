class SocialList {
  final String imageAdd;
  final String text;

  SocialList({required this.imageAdd, required this.text});
}

List<SocialList> socialMediaList = [
  SocialList(
      imageAdd: 'assets/images/login.jpg', text: "Social Media/\nOnline ads"),
  SocialList(imageAdd: 'assets/images/login.jpg', text: "Friend or Family"),
  SocialList(imageAdd: 'assets/images/login.jpg', text: "Youtube Ad"),
  SocialList(imageAdd: 'assets/images/login.jpg', text: "Podcast Ad"),
  SocialList(imageAdd: 'assets/images/login.jpg', text: "Online Publication"),
  SocialList(imageAdd: 'assets/images/login.jpg', text: "Other"),
];
