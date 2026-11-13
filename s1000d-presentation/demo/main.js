import React, {useState} from 'react';
import {createRoot} from 'react-dom/client';
import {S1000DDocument, parseXml, elements} from '../render/index.js';
import manifest from '../tests/fixtures/manifest.json';
import sourceManifest from '../sources/schema-evidence.json';
import '../styles/index.css';
import './screen.css';
const h=React.createElement;
const synthetic=import.meta.glob('../tests/fixtures/*.xml',{query:'?raw',import:'default',eager:true});
const official=import.meta.glob('../sources/external/Files/samples/*.xml',{query:'?raw',import:'default',eager:true});
const probes=[...manifest.fixtures.map(x=>({...x,label:`Probe · ${x.family} · ${x.id}`,xml:synthetic[`../tests/fixtures/${x.file}`]})),
  ...sourceManifest.examples.map((x,i)=>({id:`official-${i}`,family:familyFor(x.selectedFor),label:`Official example · ${x.selectedFor.join(', ')}`,xml:official[`../${x.path}`],origin:'official-dd-fragment',url:x.url}))];
function familyFor(names) {return names.some(x=>/isolation|fault/i.test(x))?'fault':names.some(x=>/checkList/i.test(x))?'checklist':names.some(x=>/catalog|parts/i.test(x))?'ipd':names.some(x=>/Rqmts|procedural/i.test(x))?'proced':'descript';}
// A family inferred for an isolated example supplies presentation context only.
function App() {
  const initial=new URLSearchParams(location.search).get('fixture') || probes[0].id;
  const [id,setId]=useState(initial),[source,setSource]=useState(false);
  const fixture=probes.find(x=>x.id===id) || probes[0];
  let node,error;
  try {node=parseXml(fixture.xml);} catch(e) {error=e.message;}
  window.__probe={ready:true,node,error,fixture,probes:probes.map(({xml,...x})=>x),elements};
  return h(React.Fragment,null,
    h('header',null,h('div',null,h('p',{className:'eyebrow'},'S1000D · Issue 4.0.2'),h('h1',null,'Semantic presentation registry'),h('p',null,'Reference renderer · 1,062 elements · 377 attributes · 11 schema families')),
      h('div',{className:'controls'},h('label',null,'Example ',h('select',{value:fixture.id,onChange:e=>{setId(e.target.value);history.replaceState(null,'',`?fixture=${e.target.value}`);}},...probes.map(x=>h('option',{key:x.id,value:x.id},x.label)))),h('button',{onClick:()=>setSource(!source)},source?'Rendered output':'XML source'))),
    h('div',{className:'provenance'},fixture.origin==='official-dd-fragment'?'Official S1000D explanatory fragment. May contain placeholders; not a complete validated DMC. Family context is inferred for this isolated example.':'Synthetic structural probe. Not an official or XSD-validated DMC.',fixture.url?h('a',{href:fixture.url},'Source XML'):null),
    h('main',null,error?h('pre',{role:'alert'},error):source?h('pre',{className:'source'},fixture.xml):h(S1000DDocument,{node,family:fixture.family})),
    h('footer',null,'Inferred presentation baseline. Applicability and procedural logic are preserved as data; evaluation requires the host application.'));
}
createRoot(document.getElementById('root')).render(h(App));
