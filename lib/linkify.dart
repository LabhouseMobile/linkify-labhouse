import 'package:linkify_labhouse/src/email.dart';
import 'package:linkify_labhouse/src/url.dart';

export 'package:linkify_labhouse/src/email.dart' show EmailLinkifier, EmailElement;
export 'package:linkify_labhouse/src/phone_number.dart' show PhoneNumberLinkifier, PhoneNumberElement;
export 'package:linkify_labhouse/src/url.dart' show UrlLinkifier, UrlElement;
export 'package:linkify_labhouse/src/user_tag.dart' show UserTagLinkifier, UserTagElement;

abstract class LinkifyElement {
  final String text;
  final String originText;

  LinkifyElement(this.text, [String? originText]) : originText = originText ?? text;

  @override
  bool operator ==(other) => equals(other);

  @override
  int get hashCode => Object.hash(text, originText);

  bool equals(other) => other is LinkifyElement && other.text == text;
}

class LinkableElement extends LinkifyElement {
  final String url;

  LinkableElement(String? text, this.url, [String? originText]) : super(text ?? url, originText);

  @override
  bool operator ==(other) => equals(other);

  @override
  int get hashCode => Object.hash(text, originText, url);

  @override
  bool equals(other) => other is LinkableElement && super.equals(other) && other.url == url;
}

/// Represents an element containing text
class TextElement extends LinkifyElement {
  TextElement(String text) : super(text);

  @override
  String toString() {
    return "TextElement: '$text'";
  }

  @override
  bool operator ==(other) => equals(other);

  @override
  int get hashCode => Object.hash(text, originText);

  @override
  bool equals(other) => other is TextElement && super.equals(other);
}

abstract class Linkifier {
  const Linkifier();

  List<LinkifyElement> parse(List<LinkifyElement> elements, LinkifyOptions options);
}

class LinkifyOptions {
  /// Removes http/https from shown URLs.
  final bool humanize;

  /// Removes www. from shown URLs.
  final bool removeWww;

  /// Enables loose URL parsing (any string with "." is a URL).
  final bool looseUrl;

  /// When used with [looseUrl], default to `https` instead of `http`.
  final bool defaultToHttps;

  /// Excludes `.` at end of URLs.
  final bool excludeLastPeriod;

  const LinkifyOptions({
    this.humanize = true,
    this.removeWww = false,
    this.looseUrl = false,
    this.defaultToHttps = false,
    this.excludeLastPeriod = true,
  });
}

const _urlLinkifier = UrlLinkifier();
const _emailLinkifier = EmailLinkifier();
const defaultLinkifiers = [_urlLinkifier, _emailLinkifier];

/// Turns [text] into a list of [LinkifyElement]
///
/// Use [humanize] to remove http/https from the start of the URL shown.
/// Will default to `false` (if `null`)
///
/// Uses [linkTypes] to enable some types of links (URL, email).
/// Will default to all (if `null`).
List<LinkifyElement> linkify(
  String text, {
  LinkifyOptions options = const LinkifyOptions(),
  List<Linkifier> linkifiers = defaultLinkifiers,
}) {
  var list = <LinkifyElement>[TextElement(text)];

  if (text.isEmpty) {
    return [];
  }

  if (linkifiers.isEmpty) {
    return list;
  }

  for (var linkifier in linkifiers) {
    list = linkifier.parse(list, options);
  }

  return list;
}
