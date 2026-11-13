export const kebab = name => name.replace(/([a-z0-9])([A-Z])/g, '$1-$2').replace(/[^a-zA-Z0-9-]/g, '-').toLowerCase();
const positive = v => /^\d+$/.test(v || '') && Number(v) > 0 && Number(v) <= 10000 ? Number(v) : undefined;
export {positive};

export function safeUrl(value, {image = false} = {}) {
  if (typeof value !== 'string' || /[\u0000-\u0020\u007f]/.test(value)) return undefined;
  if (/^(https?:|mailto:)/i.test(value)) return image && /^mailto:/i.test(value) ? undefined : value;
  if (/^(#|\.\.?\/|\/[^/])/.test(value)) return value;
  if (!/[:\\]/.test(value) && !value.startsWith('//')) return value;
  return undefined;
}

export function attributeProps(attrs, mapping = {}) {
  const props = { 'data-s1000d-attributes': JSON.stringify(attrs) }, style = {};
  for (const [key, value] of Object.entries(attrs)) props[`data-s1000d-attr-${kebab(key)}`] = value;
  if (attrs.id) props.id = attrs.id;
  if (attrs['xml:lang']) props.lang = attrs['xml:lang'];
  if (['ltr','rtl'].includes(attrs['dir'])) props.dir = attrs.dir;
  if (['left','right','center','justify'].includes(attrs.align)) style.textAlign = attrs.align;
  if (['top','middle','bottom'].includes(attrs.valign)) style.verticalAlign = attrs.valign;
  for (const [key, target] of [['reproductionWidth','width'],['reproductionHeight','height'],['multimediaObjectWidth','width'],['multimediaObjectHeight','height']]) {
    if (/^\d+(\.\d+)?(px|mm|cm|in|pt|%)$/.test(attrs[key] || '')) style[target] = attrs[key];
  }
  if (Object.keys(style).length) props.style = style;
  return props;
}
