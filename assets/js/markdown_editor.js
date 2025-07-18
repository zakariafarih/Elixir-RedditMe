/**
 * Markdown Editor Integration using EasyMDE
 * Provides rich markdown editing with preview, word count, and validation
 */

class MarkdownEditor {
  constructor(textarea, options = {}) {
    this.textarea = textarea;
    this.options = {
      maxLength: options.maxLength || 10000,
      showWordCount: options.showWordCount !== false,
      showCheatSheet: options.showCheatSheet !== false,
      ...options
    };
    
    this.init();
  }

  init() {
    // Load EasyMDE CSS and JS
    this.loadEasyMDE().then(() => {
      this.setupEditor();
      this.setupWordCounter();
      this.setupCheatSheet();
      this.setupValidation();
    });
  }

  async loadEasyMDE() {
    return new Promise((resolve) => {
      // Load CSS
      if (!document.querySelector('link[href*="easymde"]')) {
        const css = document.createElement('link');
        css.rel = 'stylesheet';
        css.href = 'https://cdn.jsdelivr.net/npm/easymde@2.18.0/dist/easymde.min.css';
        document.head.appendChild(css);
      }

      // Load JS
      if (!window.EasyMDE) {
        const script = document.createElement('script');
        script.src = 'https://cdn.jsdelivr.net/npm/easymde@2.18.0/dist/easymde.min.js';
        script.onload = resolve;
        document.head.appendChild(script);
      } else {
        resolve();
      }
    });
  }

  setupEditor() {
    this.editor = new EasyMDE({
      element: this.textarea,
      autoDownloadFontAwesome: false,
      spellChecker: false,
      status: false, // We'll create our own status bar
      placeholder: this.textarea.placeholder || 'Start writing your topic content...',
      toolbar: [
        'bold', 'italic', 'heading', '|',
        'quote', 'unordered-list', 'ordered-list', '|',
        'link', 'image', '|',
        'preview', 'side-by-side', 'fullscreen', '|',
        {
          name: 'clear',
          action: (editor) => {
            if (confirm('Are you sure you want to clear all content?')) {
              editor.value('');
            }
          },
          className: 'fa fa-trash',
          title: 'Clear Content'
        }
      ],
      renderingConfig: {
        singleLineBreaks: false,
        codeSyntaxHighlighting: true,
      }
    });

    // Sync with original textarea for form submission
    this.editor.codemirror.on('change', () => {
      this.textarea.value = this.editor.value();
      this.updateWordCount();
      this.validateContent();
    });
  }

  setupWordCounter() {
    if (!this.options.showWordCount) return;

    const statusBar = document.createElement('div');
    statusBar.className = 'markdown-status-bar flex justify-between items-center p-2 bg-gray-50 border-t text-sm text-gray-600';
    
    this.wordCountElement = document.createElement('span');
    this.charCountElement = document.createElement('span');
    
    statusBar.appendChild(this.wordCountElement);
    statusBar.appendChild(this.charCountElement);
    
    this.textarea.parentNode.appendChild(statusBar);
    this.updateWordCount();
  }

  setupCheatSheet() {
    if (!this.options.showCheatSheet) return;

    const cheatSheet = document.createElement('div');
    cheatSheet.className = 'markdown-cheat-sheet mt-4';
    cheatSheet.innerHTML = `
      <details class="bg-blue-50 border border-blue-200 rounded-lg">
        <summary class="cursor-pointer p-3 font-medium text-blue-800 hover:bg-blue-100">
          📝 Markdown Cheat Sheet
        </summary>
        <div class="p-4 pt-0 grid grid-cols-1 md:grid-cols-2 gap-4 text-sm">
          <div>
            <h4 class="font-semibold text-gray-800 mb-2">Text Formatting</h4>
            <div class="space-y-1 font-mono text-xs">
              <div><strong>**bold text**</strong></div>
              <div><em>*italic text*</em></div>
              <div><code>\`inline code\`</code></div>
              <div>~~strikethrough~~</div>
            </div>
          </div>
          <div>
            <h4 class="font-semibold text-gray-800 mb-2">Structure</h4>
            <div class="space-y-1 font-mono text-xs">
              <div># Heading 1</div>
              <div>## Heading 2</div>
              <div>- Bullet point</div>
              <div>1. Numbered list</div>
              <div>> Quote</div>
            </div>
          </div>
        </div>
      </details>
    `;
    
    this.textarea.parentNode.appendChild(cheatSheet);
  }

  setupValidation() {
    this.validationElement = document.createElement('div');
    this.validationElement.className = 'markdown-validation mt-2 text-sm';
    this.textarea.parentNode.appendChild(this.validationElement);
  }

  updateWordCount() {
    if (!this.wordCountElement) return;
    
    const content = this.editor.value();
    const words = content.trim() ? content.trim().split(/\s+/).length : 0;
    const chars = content.length;
    
    this.wordCountElement.textContent = `${words} words`;
    this.charCountElement.textContent = `${chars}/${this.options.maxLength} characters`;
    
    // Update color based on limit
    if (chars > this.options.maxLength * 0.9) {
      this.charCountElement.className = 'text-red-600 font-medium';
    } else if (chars > this.options.maxLength * 0.7) {
      this.charCountElement.className = 'text-yellow-600 font-medium';
    } else {
      this.charCountElement.className = 'text-gray-600';
    }
  }

  validateContent() {
    if (!this.validationElement) return;
    
    const content = this.editor.value();
    const chars = content.length;
    
    if (chars > this.options.maxLength) {
      this.validationElement.innerHTML = `
        <div class="flex items-center text-red-600">
          <svg class="w-4 h-4 mr-1" fill="currentColor" viewBox="0 0 20 20">
            <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clip-rule="evenodd"/>
          </svg>
          Content exceeds maximum length of ${this.options.maxLength} characters
        </div>
      `;
      this.textarea.setCustomValidity('Content is too long');
    } else {
      this.validationElement.innerHTML = '';
      this.textarea.setCustomValidity('');
    }
  }

  getValue() {
    return this.editor.value();
  }

  setValue(content) {
    this.editor.value(content);
  }

  focus() {
    this.editor.codemirror.focus();
  }
}

// Auto-initialize editors on page load
document.addEventListener('DOMContentLoaded', () => {
  const markdownTextareas = document.querySelectorAll('textarea[data-markdown-editor]');
  
  markdownTextareas.forEach(textarea => {
    const options = {
      maxLength: parseInt(textarea.dataset.maxLength) || 10000,
      showWordCount: textarea.dataset.showWordCount !== 'false',
      showCheatSheet: textarea.dataset.showCheatSheet !== 'false'
    };
    
    new MarkdownEditor(textarea, options);
  });
});

// Export for manual initialization
window.MarkdownEditor = MarkdownEditor;
