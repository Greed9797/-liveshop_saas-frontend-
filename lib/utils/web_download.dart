// Trigger browser download de CSV/text em Flutter Web.
// Usa dart:html — só funciona em build web. Em mobile this throws (não usar).
import 'dart:convert';
import 'dart:html' as html;

void downloadTextFile({
  required String filename,
  required String content,
  String mimeType = 'text/csv;charset=utf-8',
}) {
  // BOM para Excel reconhecer UTF-8 corretamente.
  final bytes = utf8.encode('﻿$content');
  final blob = html.Blob([bytes], mimeType);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..download = filename
    ..style.display = 'none';
  html.document.body!.append(anchor);
  anchor.click();
  anchor.remove();
  html.Url.revokeObjectUrl(url);
}

String csvEscape(String v) {
  if (v.contains(',') || v.contains('"') || v.contains('\n')) {
    return '"${v.replaceAll('"', '""')}"';
  }
  return v;
}

String csvRow(List<String> cells) =>
    cells.map(csvEscape).join(';'); // ; favorece Excel pt-BR

String buildCsv({required List<String> headers, required List<List<String>> rows}) {
  final lines = <String>[csvRow(headers), for (final r in rows) csvRow(r)];
  return lines.join('\r\n');
}
