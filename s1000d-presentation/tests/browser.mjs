import fs from 'node:fs';
import path from 'node:path';
import {createServer} from 'vite';
import {chromium} from '@playwright/test';
import assert from 'node:assert/strict';
const server=await createServer({server:{host:'127.0.0.1',port:5173,strictPort:true}});
await server.listen();
let browser;
const out='tests/visual'; fs.mkdirSync(out,{recursive:true});
try {
  browser=await chromium.launch({executablePath:process.env.CHROMIUM_PATH || '/usr/bin/chromium',headless:true,args:['--no-sandbox']});
  const page=await browser.newPage({viewport:{width:1440,height:1000},deviceScaleFactor:1});
  const errors=[];page.on('pageerror',e=>errors.push(e.message));
  await page.goto('http://127.0.0.1:5173');await page.waitForFunction(()=>window.__probe?.ready);
  const probes=await page.evaluate(()=>window.__probe.probes);
  const results=[];
  for(const probe of probes) {
    await page.goto(`http://127.0.0.1:5173/?fixture=${encodeURIComponent(probe.id)}`);
    await page.waitForFunction(()=>window.__probe?.ready);
    const r=await page.evaluate(()=>{
      const {node,error}=window.__probe, root=document.querySelector('.s1000d-document');
      const normalize=s=>s.replace(/\s+/g,' ').trim();
      const text=n=>n.type==='text'?n.value:(n.children||[]).map(text).join('');
      const copy=root?.cloneNode(true);copy?.querySelectorAll('[data-s1000d-generated]').forEach(n=>n.remove());
      const visited=[],attrs=[];
      function walk(n){if(n.type==='element'){visited.push(n.name);attrs.push(...Object.keys(n.attributes));n.children.forEach(walk);}}
      if(node)walk(node);
      const applicable=document.getElementById('applic-visible');
      return {error,sourceText:node?normalize(text(node)):null,renderedText:normalize(copy?.textContent||''),
        elements:[...new Set(visited)],attributes:[...new Set(attrs)],
        contextRules:[...new Set([...root?.querySelectorAll('[data-s1000d-rules]')||[]].flatMap(n=>n.dataset.s1000dRules.split(' ')).filter(Boolean))],
        styleLoaded:!!getComputedStyle(root).getPropertyValue('--s1000d-warning').trim(),
        visibleApplicability:applicable?getComputedStyle(applicable).display!=='none':null,
        documentOverflow:document.documentElement.scrollWidth>innerWidth,
        tables:root?.querySelectorAll('table').length||0};
    });
    assert.equal(r.error,undefined,`${probe.id}: parse`);
    assert.equal(r.renderedText,r.sourceText,`${probe.id}: meaningful text order`);
    assert.ok(r.styleLoaded,`${probe.id}: CSS loaded`);
    assert.notEqual(r.visibleApplicability,false,`${probe.id}: applicability content visible`);
    assert.equal(r.documentOverflow,false,`${probe.id}: horizontal viewport overflow`);
    await page.screenshot({path:path.join(out,`${probe.id}.png`),fullPage:true});
    results.push({id:probe.id,family:probe.family,origin:probe.origin,url:probe.url,passed:true,
      checks:['parse','meaningful-text-order','css-loaded','applicability-visible','no-viewport-overflow'],
      ...Object.fromEntries(Object.entries(r).filter(([k])=>!['error','sourceText','renderedText'].includes(k))),screenshot:`tests/visual/${probe.id}.png`});
  }
  await page.setViewportSize({width:390,height:844});
  await page.goto('http://127.0.0.1:5173/?fixture=edge-cases');await page.waitForFunction(()=>window.__probe?.ready);
  assert.ok(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),'Mobile overflow');
  await page.screenshot({path:path.join(out,'edge-cases-mobile.png'),fullPage:true});
  assert.deepEqual(errors,[], 'Browser runtime errors');
  const report={format:'s1000d-browser-validation',renderer:'included-reference-react-renderer',browser:await browser.version(),timestamp:new Date().toISOString(),
    viewport:{desktop:[1440,1000],mobile:[390,844]},fixtureCount:results.length,results,
    elementsExercised:[...new Set(results.flatMap(x=>x.elements))].sort(),attributesExercised:[...new Set(results.flatMap(x=>x.attributes))].sort(),
    contextRulesExercised:[...new Set(results.flatMap(x=>x.contextRules))].sort(),
    visualApproval:'not-approved',limitations:['Official DD examples are fragments, not whole schema-valid DMCs.','Synthetic probes are not production documents.','Screenshots are initial baselines; visual checks are not a regression comparison until baselines are approved.','Host application renderer not provided.']};
  fs.writeFileSync(path.join(out,'browser-report.json'),JSON.stringify(report,null,2)+'\n');
  console.log(`${results.length} fixtures passed browser checks; ${report.elementsExercised.length} unique XML elements, ${report.attributesExercised.length} attributes; desktop and mobile screenshots saved.`);
} finally {await browser?.close();await server.close();}
