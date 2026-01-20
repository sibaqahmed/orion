enum MessageSender { user, orion, typing }

class ChatMessage {
  final String id;
  final String text;
  final MessageSender sender;

  ChatMessage({
    required this.id,
    required this.text,
    required this.sender,
  });

  static MessageSender senderFromString(String s) {
    switch (s) {
      case "user":
        return MessageSender.user;
      case "orion":
        return MessageSender.orion;
      default:
        return MessageSender.orion;
    }
  }

  static String senderToString(MessageSender s) {
    switch (s) {
      case MessageSender.user:
        return "user";
      case MessageSender.orion:
        return "orion";
      case MessageSender.typing:
        return "typing";
    }
  }
}
