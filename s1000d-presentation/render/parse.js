import { SaxesParser } from 'saxes';

/** Ordered, lossless content model. Attribute values and XML QName case are retained.
 * Comments/PIs are retained in the AST but intentionally have no visual output.
 * DTDs/entities require a trusted caller-side resolver; this parser never fetches them.
 */
export function parseXml(xml) {
  if (typeof xml !== 'string') throw new Error('Expected XML string');
  if (/<!DOCTYPE|<!ENTITY/i.test(xml)) throw new Error('DTD/entity declarations require a trusted external resolver before parseXml');
  let root;
  const stack = [];
  const parser = new SaxesParser({xmlns:false});
  const append = n => {if (stack.length) stack.at(-1).children.push(n);};
  parser.on('opentag', tag => {
    const node={type:'element',name:tag.name,attributes:{...tag.attributes},children:[]};
    append(node);
    if (!root) root=node;
    stack.push(node);
  });
  parser.on('closetag', () => stack.pop());
  parser.on('text', value => append({type:'text',value}));
  parser.on('cdata', value => append({type:'text',value}));
  parser.on('comment', value => append({type:'comment',value}));
  parser.on('processinginstruction', pi => append({type:'processing-instruction',name:pi.target,value:pi.body}));
  parser.write(xml).close();
  if (!root) throw new Error('Invalid XML: missing root');
  return root;
}

export function textContent(node) {
  return node.type === 'text' ? node.value : (node.children || []).map(textContent).join('');
}

/** Key-grouped XML-to-JSON loses ordering and is deliberately not guessed here. */
export function validateAst(node) {
  if (node?.type === 'text' && typeof node.value === 'string') return;
  if (node?.type === 'comment' || node?.type === 'processing-instruction') return;
  if (node?.type !== 'element' || typeof node.name !== 'string' || !Array.isArray(node.children) ||
      !node.attributes || typeof node.attributes !== 'object' || Array.isArray(node.attributes))
    throw new Error('Expected ordered AST: {type:"element", name, attributes, children}');
  if (Object.values(node.attributes).some(v => typeof v !== 'string')) throw new Error('XML attribute values must be strings');
  node.children.forEach(validateAst);
}
