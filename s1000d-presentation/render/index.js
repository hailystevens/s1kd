import React from 'react';
import elements from '../registry/elements.json' with {type:'json'};
import attributes from '../registry/attributes.json' with {type:'json'};
import rules from '../registry/contextual-rules.json' with {type:'json'};
import {attributeProps, positive, safeUrl} from './attributes.js';
import {validateAst, textContent} from './parse.js';
export {parseXml, textContent, validateAst} from './parse.js';
export {elements, attributes, rules};
const h = React.createElement;
const childrenOf = (node, name) => node.children.filter(x => x.type === 'element' && (!name || x.name === name));

export function resolveMapping(node, context = {}) {
  const base = elements[node.name] || {element:node.name, role:'unknown', component:'Container', htmlTag:'span', cssClass:'s1000d-unknown', confidence:0, limitations:['Unregistered XML element; content preserved']};
  const result = {...base, classes:[], props:{}, appliedRules:[]};
  for (const rule of [...rules].sort((a,b) => a.priority - b.priority)) {
    const m = rule.match;
    if (m.elements?.length && !m.elements.includes(node.name)) continue;
    if (m.parents?.length && !m.parents.includes(context.parent)) continue;
    if (m.ancestors?.length && !m.ancestors.some(a => context.ancestors?.includes(a))) continue;
    if (m.families?.length && !m.families.includes(context.family)) continue;
    if (m.attributes && !Object.entries(m.attributes).every(([k,v]) => v === '*' ? k in node.attributes : (Array.isArray(v) ? v.includes(node.attributes[k]) : node.attributes[k] === v))) continue;
    const {classes = [], props = {}, ...rest} = rule.apply;
    Object.assign(result, rest);
    result.classes.push(...classes); Object.assign(result.props, props); result.appliedRules.push(rule.id);
  }
  return result;
}

/** One renderer for all vocabulary; specialized handlers only for real structural behavior.
 * Callbacks receive exact XML attributes. They never infer diagnostic/applicability actions.
 */
export function S1000DDocument({node, family, resolveReference, resolveMedia, className = '', onDiagnostic}) {
  validateAst(node);
  const diagnostics = [];
  const localIds=new Set();
  function indexIds(n) {if(n.type==='element'){if(n.attributes.id)localIds.add(n.attributes.id);n.children.forEach(indexIds);}}
  indexIds(node);
  function warn(code, n, detail) {diagnostics.push({code, element:n.name, id:n.attributes.id, detail});}
  function render(n, ctx = {}, key = '0') {
    if (n.type === 'text') return n.value;
    if (n.type !== 'element') return null;
    const map = resolveMapping(n, {...ctx, family});
    const props = {...attributeProps(n.attributes, map), ...map.props, key,
      className:[map.cssClass,...map.classes].filter(Boolean).join(' '), 'data-s1000d-element':n.name,
      'data-s1000d-role':map.role, 'data-s1000d-rules':map.appliedRules.join(' ')};
    if (!elements[n.name]) warn('unknown-element',n,'Visible content-preserving fallback');
    if (n.attributes.applicRefId || n.attributes.visibility) props['data-s1000d-evaluation'] = 'not-evaluated';
    const next = {...ctx, parent:n.name, ancestors:[...(ctx.ancestors || []),n.name]};
    const content = () => n.children.map((c,i) => render(c,next,`${key}.${i}`));
    const badge = label => h('span', {'data-s1000d-generated':'label',className:'s1000d-label',key:`${key}.label`}, label);
    const rawFields = () => Object.entries(n.attributes).filter(([k]) => !/^(id|xmlns(:|$)|xsi:|xml:)/.test(k)).map(([k,v]) => h('span', {key:k,className:'s1000d-attribute-value','data-s1000d-generated':'attribute'}, `${k}: ${v} `));
    let tag = map.htmlTag || 'span';
    // P cannot contain arbitrary block children. A role paragraph div preserves XML containment.
    function hasBlock(node) {return childrenOf(node).some(c => elements[c.name]?.display === 'block' || !elements[c.name] || hasBlock(c));}
    if (tag === 'p' && hasBlock(n)) {tag = 'div'; props.role = 'paragraph';}
    if (n.name === 'table') return renderTable(n,props,next,key);
    if (n.name === 'tgroup') return renderGroup(n,props,next,key);
    if (n.name === 'title' && ctx.parent === 'figure') tag = 'figcaption';
    if (n.name === 'title' && ctx.parent === 'table') tag = 'div';
    if (n.name === 'entry') {
      tag = ctx.inHead ? 'th' : 'td';
      if (!ctx.inTable) {tag='div'; warn('orphan-table-cell',n,'Preserved outside table');}
      if (ctx.cellPlacement) Object.assign(props,ctx.cellPlacement);
      if (tag === 'th') props.scope = 'col';
    }
    if (n.name === 'row' && !ctx.inTable) tag='div';
    if (['thead','tbody','tfoot'].includes(n.name) && !ctx.inTable) tag='div';
    if (n.name === 'colspec' || n.name === 'spanspec') return h('span',{...props,hidden:true});
    if (['proceduralStep','isolationStep','checkListStep','crewDrillStep'].includes(n.name)) {
      tag = 'section';
      return h(tag, props, badge(n.attributes.stepLabel || `Step ${ctx.stepNumber || 1}`), ...stepContent(n,next,key));
    }
    if (['mainProcedure','isolationMainProcedure','proceduralStepAlt'].includes(n.name)) return h('section',props,...stepContent(n,next,key));
    if (map.component === 'Safety' && ['warning','caution','note'].includes(n.name)) return h('aside',props,badge(n.name.toUpperCase()),...content());
    if (map.component === 'Reference' || n.attributes.nextActionRefId) {
      const target = n.attributes.internalRefId || n.attributes.nextActionRefId;
      if(target && !localIds.has(target)) {
        props['data-s1000d-unresolved-reference']='true';
        warn('unresolved-internal-target',n,`Target is not present in this rendered XML tree: ${target}`);
      }
      let uri = target ? `#${encodeURIComponent(target)}` : resolveReference?.(n, {family});
      uri = safeUrl(uri);
      // Nested references remain spans to avoid invalid nested anchors.
      tag = uri && !ctx.inLink ? 'a' : 'span';
      if (tag === 'a') props.href = uri;
      else if (!ctx.inLink) {props['data-s1000d-unresolved-reference']='true'; warn('unresolved-reference',n,'No validated reference resolver/target');}
      const refChildren = n.children.map((c,i) => render(c,{...next,inLink:ctx.inLink || tag === 'a'},`${key}.${i}`));
      if (!textContent(n).trim() && ['yesAnswer','noAnswer'].includes(n.name)) refChildren.push(badge(n.name === 'yesAnswer' ? 'Yes' : 'No'));
      if (!textContent(n).trim()) refChildren.push(...rawFields());
      return h(tag,props,...refChildren);
    }
    if (['graphic','multimediaObject','symbol','logo'].includes(n.name)) {
      const resource = resolveMedia?.(n,{family});
      const url = safeUrl(typeof resource === 'string' ? resource : resource?.src,{image:true});
      return h('span', {...props,className:`${props.className} s1000d-media-slot`},
        url ? h('img',{src:url,alt:resource?.alt || n.attributes.infoEntityIdent || n.name,loading:'lazy'}) : h('span',{'data-s1000d-generated':'placeholder',className:'s1000d-media-placeholder'},`Unresolved ${n.name}: ${n.attributes.infoEntityIdent || n.attributes.id || 'no resource identifier'}`),
        ...content());
    }
    if (['ul','ol','dl'].includes(tag)) {
      // XML list titles stay in source order; HTML marker layout uses semantic roles.
      tag='div'; props.role = tag === 'dl' || map.component === 'DefinitionList' ? 'list' : 'list';
    }
    if (map.component === 'Heading' && !['figcaption','caption'].includes(tag) && ctx.parent !== 'table') {
      props.role = 'heading';
      props['aria-level'] = map.props['aria-level'] || Math.min(6,2 + (ctx.ancestors || []).filter(x=>['levelledPara','proceduralStep','pmEntry'].includes(x)).length);
    }
    if (['li','dt','dd'].includes(tag)) {tag='div'; props.role = 'listitem';}
    if (['h1','h2','h3','h4','h5','h6'].includes(tag)) {
      const depth = 1 + (ctx.ancestors || []).filter(x => ['levelledPara','proceduralStep','pmEntry','section'].includes(x)).length;
      tag=`h${Math.min(6,depth+1)}`;
      // Mixed/structural children are legal in div headings.
      if (childrenOf(n).some(c => elements[c.name]?.display === 'block')) {props.role='heading';props['aria-level']=Math.min(6,depth+1);tag='div';}
    }
    // Preserve attribute-only technical values as visible inspection data, never as instructions.
    const values = !textContent(n).trim() && childrenOf(n).length === 0 && !['colspec','spanspec'].includes(n.name) ? rawFields() : [];
    if (!textContent(n).trim() && childrenOf(n).length === 0 && map.emptyLabel)
      values.unshift(badge(map.emptyLabel));
    return h(tag,props,...content(),...values);
  }
  function stepContent(n,ctx,key) {
    let number=0;
    return n.children.map((c,i) => render(c,{...ctx,stepNumber:c.type === 'element' && /^(proceduralStep|isolationStep|checkListStep|crewDrillStep)$/.test(c.name) ? ++number : undefined},`${key}.${i}`));
  }
  function renderTable(n,props,ctx,key) {
    // CALS allows multiple tgroups; each is a real HTML table in one XML wrapper.
    const title=childrenOf(n,'title')[0];
    return h('div',{...props,tabIndex:0,role:'region','aria-label':title?textContent(title):'Technical table',className:`${props.className} s1000d-table-wrapper`},...n.children.map((c,i) => render(c,ctx,`${key}.${i}`)));
  }
  function renderGroup(n,props,ctx,key) {
    const structuralProps=(node,parent,nodeKey,ancestors=ctx.ancestors)=>{
      const map=resolveMapping(node,{parent,ancestors,family});
      return {...attributeProps(node.attributes),...map.props,key:nodeKey,
        className:[map.cssClass,...map.classes].join(' '),'data-s1000d-element':node.name,
        'data-s1000d-role':map.role,'data-s1000d-rules':map.appliedRules.join(' ')};
    };
    // Native table DOM cannot preserve arbitrary children. Keep the entire malformed
    // structure in ordered block wrappers instead of allowing browser foster parenting.
    const allowed=(x,names)=>x.type !== 'element' ? x.type !== 'text' || !x.value.trim() : names.includes(x.name);
    const malformed=n.children.some(x=>!allowed(x,['colspec','spanspec','thead','tbody','tfoot'])) ||
      childrenOf(n).filter(x=>['thead','tbody','tfoot'].includes(x.name)).some(s=>
        s.children.some(x=>!allowed(x,['row'])) || childrenOf(s,'row').some(r=>r.children.some(x=>!allowed(x,['entry']))));
    if(malformed) {
      warn('unsupported-table-structure',n,'Entire group rendered in original order using readable fallback wrappers');
      return h('div',{...props,'data-s1000d-table-fallback':'true'},...n.children.map((c,i)=>render(c,{...ctx,inTable:false},`${key}.fallback${i}`)));
    }
    const specs=childrenOf(n,'colspec'), spans=childrenOf(n,'spanspec');
    const cols = new Map(), specsByColumn=new Map(); let col=0, invalidGrid=false;
    if (n.attributes.cols !== undefined && !positive(n.attributes.cols)) invalidGrid=true;
    for (const s of specs) {
      if (s.attributes.colnum !== undefined && !positive(s.attributes.colnum)) invalidGrid=true;
      col=positive(s.attributes.colnum) || col+1;
      if (col>10000 || specsByColumn.has(col) || (s.attributes.colname && cols.has(s.attributes.colname))) invalidGrid=true;
      specsByColumn.set(col,s);
      if(s.attributes.colname) cols.set(s.attributes.colname,col);
    }
    const spanMap=new Map(spans.map(s=>[s.attributes.spanname,s.attributes]));
    const total=positive(n.attributes.cols) || Math.max(col,1);
    if ([...specsByColumn.keys()].some(number=>number>total)) invalidGrid=true;
    if (invalidGrid) {
      warn('invalid-cals-grid',n,'Column declarations conflict or exceed the supported 1–10000 grid; original structure retained in readable wrappers');
      return h('div',{...props,'data-s1000d-table-fallback':'true'},...n.children.map((c,i)=>render(c,{...ctx,inTable:false},`${key}.grid-fallback${i}`)));
    }
    // Each physical column occupies its declared position, including unnamed gaps.
    const slots=Array.from({length:total},(_,i)=>specsByColumn.get(i+1));
    const starWeight=width=>{
      const weight=/^(?:\d+(?:\.\d+)?)?\*$/.test(width || '') ? Number(width.slice(0,-1) || 1) : undefined;
      return Number.isFinite(weight) && weight>0 && weight<=1e9?weight:undefined;
    };
    const allStar=slots.every(s=>s && starWeight(s.attributes.colwidth)>0);
    const starTotal=allStar?slots.reduce((sum,s)=>sum+starWeight(s.attributes.colwidth),0):0;
    const colElements=slots.map((s,i)=>{
      if(!s) return h('col',{key:i,'data-s1000d-generated':'empty-layout-column'});
      const width=s.attributes.colwidth;
      let cssWidth=/^\d+(\.\d+)?(px|mm|cm|in|pt|%)$/.test(width||'')?width:undefined;
      if(allStar) cssWidth=`${100*starWeight(width)/starTotal}%`;
      else if(width !== undefined && !cssWidth) warn('unsupported-cals-width',s,'Only physical/percentage widths and a complete all-star column grid are resolved; original width retained');
      return h('col',{...structuralProps(s,'tgroup',i),style:cssWidth?{width:cssWidth}:undefined});
    });
    let occupied=[];
    function section(s,idx) {
      if (s.type === 'text') return s.value.trim() ? h('caption',{key:idx},s.value) : s.value;
      if (s.type !== 'element') return null;
      if (['colspec','spanspec'].includes(s.name)) return null;
      if (!['thead','tbody','tfoot'].includes(s.name)) {
        warn('unsupported-table-child',s,'Preserved outside native table in XML order');
        return null;
      }
      occupied=[]; // HTML row spans cannot cross row groups.
      return h(s.name,structuralProps(s,'tgroup',idx),...s.children.map((r,ri)=>{
        if(r.type !== 'element' || r.name !== 'row') return r.type==='text' && !r.value.trim() ? r.value : null;
        const active=occupied.map(v=>Math.max(0,v-1)); let cursor=1;
        const rendered=r.children.map((cell,ci)=>{
          if(cell.type !== 'element' || cell.name !== 'entry') return cell.type==='text' && !cell.value.trim() ? cell.value : null;
          const span=spanMap.get(cell.attributes.spanname);
          const a={...(span||{}),...cell.attributes};
          let unresolved=false;
          if(cell.attributes.spanname !== undefined && !span) {
            warn('unresolved-cals-span',cell,`Unknown spanname: ${cell.attributes.spanname}`); unresolved=true;
          }
          for(const name of ['namest','nameend','colname']) if(a[name] !== undefined && !cols.has(a[name])) {
            warn('unresolved-cals-column',cell,`Unknown ${name}: ${a[name]}`); unresolved=true;
          }
          while((occupied[cursor-1] || 0)>0) cursor++;
          const start=cols.get(a.namest) || cols.get(a.colname) || cursor;
          const end=cols.get(a.nameend) || start;
          const colSpan=end-start+1, rowSpan=/^\d+$/.test(a.morerows||'') ? Number(a.morerows)+1 : 1;
          const invalid=unresolved || start<cursor || start<1 || end>total || colSpan<1 || rowSpan>10000 || Array.from({length:Math.max(0,colSpan)},(_,i)=>occupied[start+i-1]||0).some(Boolean);
          if(invalid) warn('invalid-cals-span',cell,'Conflicting/invalid placement retained as readable cell; original attrs preserved');
          // Cell-local data attributes remain the exact XML input. Resolved inherited
          // properties are exposed separately and materialized as safe inline styles.
          const effective={...n.attributes,...(specsByColumn.get(invalid?cursor:start)?.attributes||{}),...(span||{}),...s.attributes,...r.attributes,...cell.attributes};
          const style={...(attributeProps(cell.attributes).style||{})}, place=!invalid?{colSpan,rowSpan}:{};
          for(const attr of ['align','valign','rowsep','colsep']) if(effective[attr] !== undefined) place[`data-s1000d-effective-${attr}`]=effective[attr];
          if(['left','right','center','justify'].includes(effective.align)) style.textAlign=effective.align;
          else if(effective.align==='char') warn('unsupported-cals-character-alignment',cell,'Character alignment needs a text measurement adapter; value preserved');
          if(['top','middle','bottom','baseline'].includes(effective.valign)) style.verticalAlign=effective.valign;
          if(['0','1'].includes(effective.rowsep)) style.borderBottom=effective.rowsep==='0'?'0':'1px solid var(--s1000d-line)';
          if(['0','1'].includes(effective.colsep)) style.borderInlineEnd=effective.colsep==='0'?'0':'1px solid var(--s1000d-line)';
          if(Object.keys(style).length) place.style=style;
          const placeholders=[];
          if(!invalid) while(cursor<start) {if(!(occupied[cursor-1]>0)) placeholders.push(h('td', {key:`gap${ci}-${cursor}`,'data-s1000d-generated':'empty-layout-cell'}));cursor++;}
          if(!invalid) for(let c=start;c<=end;c++) active[c-1]=rowSpan-1;
          cursor=invalid?cursor+1:Math.max(cursor,end+1);
          return [...placeholders,render(cell,{...ctx,parent:'row',inTable:true,inHead:s.name==='thead',cellPlacement:place,ancestors:[...(ctx.ancestors||[]),s.name,'row']},`${key}.${idx}.${ri}.${ci}`)];
        });
        occupied=active;
        return h('tr',structuralProps(r,s.name,ri,[...(ctx.ancestors||[]),s.name]),...rendered);
      }));
    }
    const native=h('table',{...props,'data-s1000d-element':'tgroup',key:`${key}.table`},
      h('colgroup',null,...colElements),
      ...n.children.map(section));
    return native;
  }
  const output = render(node,{parent:null,ancestors:[],family});
  if(onDiagnostic) diagnostics.forEach(onDiagnostic);
  return h('article',{className:`s1000d-document ${className}`,'data-s1000d-family':family || 'unspecified'},output);
}
