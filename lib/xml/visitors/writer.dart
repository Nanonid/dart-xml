part of xml;

/**
 * A visitor that writes XML nodes eactly as they were parsed.
 */

class XmlWriter extends XmlVisitor {

  final StringBuffer buffer;

  XmlWriter(this.buffer);

  @override
  String toString() => buffer.toString();

  @override
  visitAttribute(XmlAttribute node) {
    visit(node.name);
    buffer.write(XmlGrammar.EQUALS);
    buffer.write(XmlGrammar.DOUBLE_QUOTE);
    buffer.write(_encodeXmlAttributeValue(node.value));
    buffer.write(XmlGrammar.DOUBLE_QUOTE);
  }

  @override
  visitCDATA(XmlCDATA node) {
    buffer.write(XmlGrammar.OPEN_CDATA);
    buffer.write(node.text);
    buffer.write(XmlGrammar.CLOSE_CDATA);
  }

  @override
  visitComment(XmlComment node) {
    buffer.write(XmlGrammar.OPEN_COMMENT);
    buffer.write(node.text);
    buffer.write(XmlGrammar.CLOSE_COMMENT);
  }

  @override
  visitDoctype(XmlDoctype node) {
    buffer.write(XmlGrammar.OPEN_DOCTYPE);
    buffer.write(XmlGrammar.WHITESPACE);
    buffer.write(node.text);
    buffer.write(XmlGrammar.CLOSE_DOCTYPE);
  }

  @override
  visitDocument(XmlDocument node) {
    writeChildren(node);
  }

  @override
  visitElement(XmlElement node) {
    buffer.write(XmlGrammar.OPEN_ELEMENT);
    visit(node.name);
    writeAttributes(node);
    if (node.children.isEmpty) {
      buffer.write(XmlGrammar.WHITESPACE);
      buffer.write(XmlGrammar.CLOSE_END_ELEMENT);
    } else {
      buffer.write(XmlGrammar.CLOSE_ELEMENT);
      writeChildren(node);
      buffer.write(XmlGrammar.OPEN_END_ELEMENT);
      visit(node.name);
      buffer.write(XmlGrammar.CLOSE_ELEMENT);
    }
  }

  @override
  visitName(XmlName name) {
    buffer.write(name.qualified);
  }

  @override
  visitProcessing(XmlProcessing node) {
    buffer.write(XmlGrammar.OPEN_PROCESSING);
    buffer.write(node.target);
    if (!node.text.isEmpty) {
      buffer.write(XmlGrammar.WHITESPACE);
      buffer.write(node.text);
    }
    buffer.write(XmlGrammar.CLOSE_PROCESSING);
  }

  @override
  visitText(XmlText node) {
    buffer.write(_encodeXmlText(node.text));
  }

  writeAttributes(XmlNode node) {
    for (var attribute in node.attributes) {
      buffer.write(XmlGrammar.WHITESPACE);
      visit(attribute);
    }
  }

  writeChildren(XmlNode node) {
    for (var child in node.children) {
      visit(child);
    }
  }

}

class XmlPrettyWriter extends XmlWriter {

  int level = 0;
  String indent;

  XmlPrettyWriter(buffer, this.level, this.indent) : super(buffer);

  @override
  visitCDATA(XmlCDATA node) {
    newLine();
    super.visitCDATA(node);
  }

  @override
  visitComment(XmlComment node) {
    newLine();
    super.visitComment(node);
  }

  @override
  visitDoctype(XmlDoctype node) {
    newLine();
    super.visitDoctype(node);
  }

  @override
  visitElement(XmlElement node) {
    newLine();
    buffer.write('<');
    visit(node.name);
    writeAttributes(node);
    if (node.children.isEmpty) {
      buffer.write(' />');
    } else {
      buffer.write('>');
      level++;
      writeChildren(node);
      level--;
      if (!node.children.every((each) => each is XmlText)) {
        newLine();
      }
      buffer.write('</');
      visit(node.name);
      buffer.write('>');
    }
  }

  @override
  visitProcessing(XmlProcessing node) {
    newLine();
    super.visitProcessing(node);
  }

  @override
  visitText(XmlText node) {
    // If text is purely whitespace, don't output to the buffer
    // the indentation and newlines will be handled elsewhere.
    if (node.text.trim().isNotEmpty) {
      super.visitText(node);
    }
  }

  void newLine() {
    if (buffer.isNotEmpty) {
      buffer.write('\n');
    }
    for (int i = 0; i < level; i++) {
      buffer.write(indent);
    }
  }

}