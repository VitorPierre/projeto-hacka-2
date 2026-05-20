// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import * as ActiveStorage from "@rails/activestorage"

ActiveStorage.start()

document.addEventListener('turbo:load', () => {
  setupModerationChecks();
  setupDirectUploads();
});
document.addEventListener('DOMContentLoaded', () => {
  setupModerationChecks();
  setupDirectUploads();
});

function setupModerationChecks() {
  const inputs = document.querySelectorAll('[data-moderation-check="true"]');
  inputs.forEach(input => {
    // Evita duplicar listeners
    if (input.dataset.moderationListenerAttached) return;
    input.dataset.moderationListenerAttached = "true";

    let timeoutId = null;

    input.addEventListener('input', () => {
      clearTimeout(timeoutId);
      const text = input.value.trim();

      if (text.length === 0) {
        clearWarning(input);
        return;
      }

      timeoutId = setTimeout(() => {
        performModerationCheck(input, text);
      }, 400); // 400ms debounce
    });
  });
}

function performModerationCheck(input, text) {
  const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content;

  fetch('/users/check_moderation', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-CSRF-Token': csrfToken,
      'Accept': 'application/json'
    },
    body: JSON.stringify({ text: text })
  })
  .then(response => response.json())
  .then(data => {
    if (data.inappropriate) {
      showWarning(input);
    } else {
      clearWarning(input);
    }
  })
  .catch(error => {
    console.error('Erro na validação de moderação em tempo real:', error);
  });
}

function showWarning(input) {
  // Encontra ou cria a caixa de aviso
  let warningBox = input.nextElementSibling;
  if (!warningBox || !warningBox.classList.contains('moderation-warning-box')) {
    warningBox = document.createElement('div');
    warningBox.setAttribute('role', 'alert');
    warningBox.className = 'moderation-warning-box bg-amber-50 text-amber-800 border border-amber-200 rounded-xl p-3.5 mt-2 text-xs font-semibold flex items-start gap-2 shadow-sm transition-all animate-fadeIn';
    warningBox.innerHTML = `
      <svg class="w-4 h-4 text-amber-600 flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"></path>
      </svg>
      <div>
        <span class="font-bold">Atenção:</span> Detectamos termos que podem violar as diretrizes de uso da plataforma. Por favor, revise para evitar que seu perfil seja sinalizado para suspensão ou banimento.
      </div>
    `;
    input.parentNode.insertBefore(warningBox, input.nextSibling);
  }
  
  // Altera a borda do input para chamar atenção
  input.classList.add('border-amber-500', 'focus:ring-amber-500');
  input.classList.remove('border-aprende-secondary', 'focus:ring-aprende-primary');
}

function clearWarning(input) {
  const warningBox = input.nextElementSibling;
  if (warningBox && warningBox.classList.contains('moderation-warning-box')) {
    warningBox.remove();
  }
  
  // Restaura a borda padrão do input
  input.classList.remove('border-amber-500', 'focus:ring-amber-500');
  input.classList.add('border-aprende-secondary', 'focus:ring-aprende-primary');
}

function setupDirectUploads() {
  const inputs = document.querySelectorAll('input[type="file"][data-direct-upload-url]');
  inputs.forEach(input => {
    if (input.dataset.directUploadAttached) return;
    input.dataset.directUploadAttached = "true";

    const form = input.closest('form');
    // Look for a progress container or create one
    let progressContainer = form.querySelector('.direct-upload-progress-container');
    
    input.addEventListener("direct-upload:initialize", event => {
      const { target, detail } = event;
      const { id, file } = detail;
      
      if (!progressContainer) {
        progressContainer = document.createElement('div');
        progressContainer.className = 'direct-upload-progress-container w-full bg-slate-100 rounded-xl p-4 mt-3 border border-aprende-secondary/50 flex flex-col gap-2 transition-all';
        progressContainer.innerHTML = `
          <div class="flex justify-between items-center text-xs font-semibold text-aprende-text">
            <span class="truncate flex items-center gap-1.5">
              <svg class="w-4 h-4 text-aprende-primary flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 10l4.553-2.276A1 1 0 0121 8.618v6.764a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z"></path></svg>
              Enviando: <span class="text-aprende-muted font-normal">${file.name}</span>
            </span>
            <span class="direct-upload-percentage font-mono text-aprende-primary">0%</span>
          </div>
          <div class="w-full bg-slate-200 h-2.5 rounded-full overflow-hidden">
            <div class="direct-upload-bar bg-aprende-primary h-full w-0 transition-all duration-300"></div>
          </div>
        `;
        input.parentNode.insertBefore(progressContainer, input.nextSibling);
      } else {
        progressContainer.classList.remove('hidden');
        progressContainer.querySelector('.direct-upload-bar').style.width = '0%';
        progressContainer.querySelector('.direct-upload-percentage').textContent = '0%';
      }
    });

    input.addEventListener("direct-upload:start", event => {
      // Disable form submit to prevent double-submitting during upload
      const submitBtn = form.querySelector('input[type="submit"], button[type="submit"]');
      if (submitBtn) {
        submitBtn.disabled = true;
        submitBtn.classList.add('opacity-55', 'cursor-not-allowed');
        if (submitBtn.tagName === 'INPUT') {
          submitBtn.dataset.originalValue = submitBtn.value;
          submitBtn.value = "Enviando arquivo...";
        } else {
          submitBtn.dataset.originalText = submitBtn.textContent;
          submitBtn.textContent = "Enviando arquivo...";
        }
      }
    });

    input.addEventListener("direct-upload:progress", event => {
      const { id, progress } = event.detail;
      const bar = progressContainer.querySelector('.direct-upload-bar');
      const text = progressContainer.querySelector('.direct-upload-percentage');
      if (bar && text) {
        bar.style.width = `${progress}%`;
        text.textContent = `${Math.round(progress)}%`;
      }
    });

    input.addEventListener("direct-upload:error", event => {
      event.preventDefault();
      const { id, error } = event.detail;
      let errorBox = progressContainer.querySelector('.direct-upload-error-box');
      if (!errorBox) {
        errorBox = document.createElement('div');
        errorBox.className = 'direct-upload-error-box bg-red-50 text-red-800 border border-red-200 rounded-xl p-3.5 mt-2 text-xs font-semibold';
        progressContainer.appendChild(errorBox);
      }
      errorBox.innerHTML = `Erro no upload: ${error}`;
      
      const submitBtn = form.querySelector('input[type="submit"], button[type="submit"]');
      if (submitBtn) {
        submitBtn.disabled = false;
        submitBtn.classList.remove('opacity-55', 'cursor-not-allowed');
        if (submitBtn.tagName === 'INPUT') {
          submitBtn.value = submitBtn.dataset.originalValue || "Tentar Novamente";
        } else {
          submitBtn.textContent = submitBtn.dataset.originalText || "Tentar Novamente";
        }
      }
    });

    input.addEventListener("direct-upload:end", event => {
      const submitBtn = form.querySelector('input[type="submit"], button[type="submit"]');
      if (submitBtn) {
        submitBtn.disabled = false;
        submitBtn.classList.remove('opacity-55', 'cursor-not-allowed');
        if (submitBtn.tagName === 'INPUT') {
          submitBtn.value = submitBtn.dataset.originalValue || "Finalizar Envio";
        } else {
          submitBtn.textContent = submitBtn.dataset.originalText || "Finalizar Envio";
        }
      }
    });
  });
}

