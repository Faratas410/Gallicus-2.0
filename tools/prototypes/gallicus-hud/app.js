'use strict';
// Presentation fixtures only. No live game data, persistence, RNG or economy.
const $ = id => document.getElementById(id);
const fixtures = {
  normal: { pressure:4, favor:6, stake:24, coins:38, chain:'×1,5', crowd:'La gradinata ti sostiene.' },
  high: { pressure:9, favor:4, stake:42, coins:38, chain:'×2', crowd:'La gradinata stringe. Pressione alta.' },
  blocked: { pressure:8, favor:0, stake:24, coins:38, chain:'×1,5', crowd:'La gradinata blocca la quietanza.' }
};
let scenario = 'normal';
let closed = false;
function render(name) {
  scenario=name; closed=false;
  const s=fixtures[name];
  $('game').className='game'+(name!=='normal'?' high':'');
  $('result').hidden=true;
  for(const key of ['pressure','favor']){
    $(key+'-value').textContent=s[key];
    $(key+'-fill').style.width=s[key]*10+'%';
    $(key+'-fill').parentElement.setAttribute('aria-valuenow',s[key]);
  }
  $('stake-value').textContent=s.stake;
  $('coins').textContent=s.coins;
  $('chain').textContent='CATENA '+s.chain;
  $('crowd-state').textContent=s.crowd;
  $('bando-value').textContent=s.stake+' / 30';
  $('bando-fill').style.width=Math.min(s.stake/30,1)*100+'%';
  $('stage-title').innerHTML=name==='blocked'?'La folla<br>non ti lascia.':'Quanto<br>vale fermarsi?';
  $('stage-copy').innerHTML=name==='blocked'?'Il favore è esaurito.<br>La quietanza è bloccata.':'Il sigillo ha retto.<br>La posta è tua, se la prendi adesso.';
  $('cash-copy').innerHTML=s.stake+' Gloria diventano tue.<br>Il rischio si chiude qui.';
  $('risk-copy').innerHTML='Lascia '+s.stake+' Gloria in posta.<br>La gradinata stringe ancora.';
  $('cashout').disabled=name==='blocked';
  $('cashout').setAttribute('aria-describedby','cash-note');
  $('cash-note').textContent=name==='blocked'?'// BLOCCATO · Il favore della gradinata è esaurito.':`Incassi ${s.stake} Gloria. ${s.stake>=30?'Puoi chiudere il bando.':'Il bando resta incompleto.'}`;
  $('raise').disabled=false;
  $('raise-note').textContent='Pressione +1. La posta resta a rischio.';
  document.querySelectorAll('[data-scenario]').forEach(b=>b.setAttribute('aria-pressed',String(b.dataset.scenario===name)));
}
function showResult(kind){
  if(closed || (kind==='cash' && scenario==='blocked'))return;
  closed=true;
  const s=fixtures[scenario];
  $('game').classList.add('closed');
  $('result').hidden=false;
  $('result-kicker').textContent=kind==='cash'?'QUIETANZA REGISTRATA':'SECONDA INCISIONE';
  $('result-title').textContent=kind==='cash'?`${s.stake} Gloria incassate.`:'Il rischio resta aperto.';
  $('result-copy').textContent=kind==='cash'?'Il percorso si chiude. Questa anteprima mostra la conferma; non calcola ricompense o Denari.':`${s.stake} Gloria restano in posta. La Pressione sale a ${s.pressure+1}/10. Il responso successivo non è simulato.`;
  if(kind==='raise'){
    $('pressure-value').textContent=s.pressure+1;
    $('pressure-fill').style.width=(s.pressure+1)*10+'%';
    $('pressure-fill').parentElement.setAttribute('aria-valuenow',s.pressure+1);
  }
  $('cashout').disabled=true; $('raise').disabled=true;
  $('result-reset').focus();
}
document.querySelectorAll('[data-scenario]').forEach(b=>b.addEventListener('click',()=>render(b.dataset.scenario)));
$('cashout').addEventListener('click',()=>showResult('cash'));
$('raise').addEventListener('click',()=>showResult('raise'));
$('reset').addEventListener('click',()=>render('normal'));
$('result-reset').addEventListener('click',()=>{render(scenario);(scenario==='blocked'?$('raise'):$('cashout')).focus();});
$('scars-open').addEventListener('click',()=>$('scars-dialog').showModal());
render('normal');
