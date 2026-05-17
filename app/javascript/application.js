// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

document.addEventListener('turbo:load', setupModerationChecks);
document.addEventListener('DOMContentLoaded', setupModerationChecks);

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

