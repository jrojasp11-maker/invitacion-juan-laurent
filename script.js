/**
 * script.js - Invitación Juan → Laurent
 * Guarda respuesta en Supabase + confeti + mensaje final
 */

(function() {
    'use strict';

    const CONFIG = {
        supabase: {
            url: 'https://kiwstpritxeasvsfwuxk.supabase.co',
            anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imtpd3N0cHJpdHhlYXN2c2Z3dXhrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTAyNTI3MDMsImV4cCI6MjEwNTgyODcwM30.peAuws0pdwZraHI72eDaabMqbJ-syKGyTlAQFH1Nxg0'
        },
        audio: { volume: 0.15, loop: true },
        confetti: { duration: 3000, particleCount: 150, spread: 100, origin: { y: 0.6 } },
        timing: { redirectDelay: 1500 }
    };

    const state = { audioStarted: false, audioMuted: false, movieSelection: null, sushiSelection: null, isSubmitting: false };
    const elements = {};

    document.addEventListener('DOMContentLoaded', init);

    async function init() {
        cacheElements();
        setupEventListeners();
        initSupabase();
        preloadAssets();
        if (sessionStorage.getItem('envelopeOpened')) openEnvelopeInstant();
    }

    function cacheElements() {
        elements.envelopeScreen = document.getElementById('envelope-screen');
        elements.letterScreen = document.getElementById('letter-screen');
        elements.envelope = document.getElementById('envelope');
        elements.letterFull = document.getElementById('letter-full');
        elements.audioToggle = document.getElementById('audio-toggle');
        elements.audioIconOn = document.getElementById('audio-icon-on');
        elements.audioIconOff = document.getElementById('audio-icon-off');
        elements.bgMusic = document.getElementById('bg-music');
        elements.movieOptions = document.getElementById('movie-options');
        elements.sushiOptions = document.getElementById('sushi-options');
        elements.movieRadios = document.querySelectorAll('input[name="movie"]');
        elements.sushiRadios = document.querySelectorAll('input[name="sushi"]');
        elements.acceptBtn = document.getElementById('accept-btn');
        elements.declineBtn = document.getElementById('decline-btn');
        elements.loadingModal = document.getElementById('loading-modal');
        elements.errorModal = document.getElementById('error-modal');
        elements.errorMessage = document.getElementById('error-message');
        elements.errorOkBtn = document.getElementById('error-ok-btn');
    }

    function setupEventListeners() {
        elements.envelope.addEventListener('click', handleEnvelopeClick);
        elements.envelope.addEventListener('keydown', e => { if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); handleEnvelopeClick(); }});
        elements.audioToggle.addEventListener('click', toggleAudio);
        elements.movieRadios.forEach(r => r.addEventListener('change', () => handleMovieSelect(r.value)));
        elements.sushiRadios.forEach(r => r.addEventListener('change', () => handleSushiSelect(r.value)));
        elements.acceptBtn.addEventListener('click', handleAccept);
        elements.declineBtn.addEventListener('mouseover', handleDeclineHover);
        elements.declineBtn.addEventListener('touchstart', handleDeclineHover, { passive: true });
        elements.errorOkBtn.addEventListener('click', hideErrorModal);
        elements.bgMusic.addEventListener('ended', () => { if (state.audioStarted && !state.audioMuted && CONFIG.audio.loop) { elements.bgMusic.currentTime = 0; elements.bgMusic.play().catch(console.warn); }});
        elements.bgMusic.addEventListener('error', () => elements.audioToggle.style.display = 'none');
    }

    let supabase = null;
    function initSupabase() {
        if (typeof window.supabase !== 'undefined') {
            try { supabase = window.supabase.createClient(CONFIG.supabase.url, CONFIG.supabase.anonKey); console.log('Supabase OK'); }
            catch (e) { console.error('Supabase error:', e); }
        } else { setTimeout(initSupabase, 500); }
    }

    async function startAudio() {
        if (state.audioStarted) return;
        try { elements.bgMusic.volume = CONFIG.audio.volume; elements.bgMusic.loop = CONFIG.audio.loop; await elements.bgMusic.play(); state.audioStarted = true; updateAudioIcon(); }
        catch (e) { console.warn('Autoplay bloqueado:', e); }
    }
    function toggleAudio() { state.audioMuted ? elements.bgMusic.play().catch(console.warn) : elements.bgMusic.pause(); state.audioMuted = !state.audioMuted; updateAudioIcon(); }
    function updateAudioIcon() { elements.audioIconOn.classList.toggle('hidden', state.audioMuted || !state.audioStarted); elements.audioIconOff.classList.toggle('hidden', !(state.audioMuted || !state.audioStarted)); }

    function handleEnvelopeClick() {
        if (elements.envelope.classList.contains('open')) return;
        if (!state.audioStarted) startAudio();
        elements.envelope.classList.add('open');
        sessionStorage.setItem('envelopeOpened', 'true');
        setTimeout(switchToLetterScreen, 600);
    }
    function openEnvelopeInstant() { elements.envelope.classList.add('open'); switchToLetterScreen(); }
    function switchToLetterScreen() { elements.envelopeScreen.classList.remove('active'); elements.envelopeScreen.hidden = true; elements.letterScreen.hidden = false; elements.letterScreen.offsetHeight; elements.letterScreen.classList.add('active'); setTimeout(() => elements.movieOptions.querySelector('input')?.focus(), 300); }

    function handleMovieSelect(v) { state.movieSelection = v; updateAcceptBtn(); }
    function handleSushiSelect(v) { state.sushiSelection = v; updateAcceptBtn(); }
    function updateAcceptBtn() { const ok = state.movieSelection && state.sushiSelection; elements.acceptBtn.disabled = !ok; elements.acceptBtn.classList.toggle('btn-pulse', ok); }

    function handleDeclineHover() {
        if (state.isSubmitting) return;
        const btn = elements.declineBtn, vw = innerWidth, vh = innerHeight, bw = btn.offsetWidth, bh = btn.offsetHeight, pad = 20;
        let x, y; for (let i=0;i<10;i++) { x = Math.random()*(vw-bw-pad*2)+pad; y = Math.random()*(vh-bh-pad*2)+pad; const ar = elements.acceptBtn.getBoundingClientRect(); if (Math.hypot(x+bw/2-(ar.left+ar.width/2), y+bh/2-(ar.top+ar.height/2)) > 150) break; }
        btn.style.cssText = `position:fixed;left:${x}px;top:${y}px;z-index:1000;transition:transform .15s,left .3s,top .3s;transform:scale(1.1) rotate(-5deg)`;
        setTimeout(() => btn.style.transform = 'scale(1)', 150);
    }

    async function handleAccept() {
        if (state.isSubmitting || !state.movieSelection || !state.sushiSelection) return;
        state.isSubmitting = true;
        elements.acceptBtn.disabled = true; elements.acceptBtn.classList.remove('btn-pulse');
        elements.acceptBtn.querySelector('.btn-text').textContent = 'Guardando...';
        showLoadingModal();
        try {
            await saveToSupabase();
            triggerConfetti();
            setTimeout(() => { hideLoadingModal(); showThankYou(); }, CONFIG.timing.redirectDelay);
        } catch (err) { console.error(err); hideLoadingModal(); showError(err.message || 'Error al guardar'); state.isSubmitting = false; elements.acceptBtn.disabled = false; elements.acceptBtn.classList.add('btn-pulse'); elements.acceptBtn.querySelector('.btn-text').textContent = '¡Acepto la cita! 🍣🎬'; }
    }

    async function saveToSupabase() {
        if (!supabase) throw new Error('Supabase no listo');
        const { error } = await supabase.from('respuestas_cita').insert([{ genero_pelicula: state.movieSelection, sushi_favorito: state.sushiSelection, estado: 'Aceptado' }]);
        if (error) throw new Error(error.message);
    }

    function triggerConfetti() {
        if (!window.confetti) return;
        const c = { ...CONFIG.confetti, colors: ['#c0392b','#d4a574','#e8c9a0','#fdfbf7','#27ae60'], scalar: 1.2 };
        confetti({...c, particleCount: 100, origin: {y:0.5}});
        setTimeout(() => confetti({...c, particleCount: 50, angle: 60, spread: 55, origin: {x:0, y:0.7}}), 200);
        setTimeout(() => confetti({...c, particleCount: 50, angle: 120, spread: 55, origin: {x:1, y:0.7}}), 400);
        setTimeout(() => confetti({...c, particleCount: 80, origin: {y:0.4}, gravity: 0.8}), 600);
    }

    function showThankYou() {
        const ov = document.createElement('div');
        ov.className = 'thankyou-overlay';
        ov.innerHTML = `<div class="thankyou-content"><h2>¡Gracias, Laurent! 💛</h2><p>Tu respuesta quedó registrada:</p><p class="detail"><strong>Película:</strong> ${state.movieSelection} | <strong>Sushi:</strong> ${state.sushiSelection}</p><p class="note">Juan lo verá en su panel ❤️</p></div>`;
        document.body.appendChild(ov);
        if (!document.getElementById('thankyou-style')) {
            const st = document.createElement('style'); st.id = 'thankyou-style';
            st.textContent = `.thankyou-overlay{position:fixed;inset:0;background:rgba(0,0,0,.7);backdrop-filter:blur(4px);display:flex;align-items:center;justify-content:center;z-index:3000;padding:1rem;animation:fadeIn .3s}.thankyou-content{background:var(--color-paper);border-radius:var(--radius-lg);padding:2rem;max-width:400px;text-align:center;box-shadow:0 30px 60px var(--color-shadow-strong);animation:modal-pop .3s cubic-bezier(.34,1.56,.64,1)}.thankyou-content h2{font-family:var(--font-title);font-size:2rem;color:var(--color-seal);margin-bottom:1rem}.detail{font-size:1.1rem;color:var(--color-ink)!important;margin:1rem 0}.note{font-family:var(--font-title);font-size:1.3rem;color:var(--color-accent)!important}@keyframes fadeIn{from{opacity:0}to{opacity:1}}`;
            document.head.appendChild(st);
        }
    }

    function showLoadingModal() { elements.loadingModal.classList.remove('hidden'); }
    function hideLoadingModal() { elements.loadingModal.classList.add('hidden'); }
    function showError(msg) { elements.errorMessage.textContent = msg; elements.errorModal.classList.remove('hidden'); elements.errorOkBtn.focus(); }
    function hideErrorModal() { elements.errorModal.classList.add('hidden'); }
    function preloadAssets() { new Image().src = 'lirios.png'; elements.bgMusic.load(); }

    const sr = document.createElement('style'); sr.textContent = `.sr-only{position:absolute;width:1px;height:1px;padding:0;margin:-1px;overflow:hidden;clip:rect(0,0,0,0);white-space:nowrap;border:0}`; document.head.appendChild(sr);
    document.addEventListener('visibilitychange', () => { if (document.hidden && state.audioStarted && !state.audioMuted) elements.bgMusic.pause(); else if (!document.hidden && state.audioStarted && !state.audioMuted) elements.bgMusic.play().catch(console.warn); });

})();