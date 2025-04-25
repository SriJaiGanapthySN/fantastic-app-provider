class SocialList {
  final String imageAdd;
  final String text;

  SocialList({required this.imageAdd, required this.text});
}

List<SocialList> socialMediaList = [
  SocialList(imageAdd: 'assets/images/socialMedia.png', text: "Social Media/\nOnline ads"),
  SocialList(imageAdd: 'assets/images/family.png', text: "Friend or Family"),
  SocialList(imageAdd: 'assets/images/youtube.png', text: "Youtube Ad"),
  SocialList(imageAdd: 'assets/images/podcast.png', text: "Podcast Ad"),
  SocialList(imageAdd: 'assets/images/online.png', text: "Online Publication"),
  SocialList(imageAdd: 'assets/images/other.png', text: "Other"),
];