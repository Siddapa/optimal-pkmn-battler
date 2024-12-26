// @ts-nocheck
/** @license MIT modified from Pixabay's https://github.com/Pixabay/JavaScript-autoComplete */
/* eslint-disable */
export interface Options {
  minChars: number;
  delay: number;
  offsetLeft: number;
  offsetTop: number;
  cache: boolean;
  menuClass: string;
  renderItem: (suggestion: string, search: string) => string;
  onSelect: (event: Event, term: string, item: string) => void;
}

export class AutoComplete {
  private readonly element: HTMLElement;
  private readonly source: (term: string, fn: (suggestions: string[]) => void) => void;
  private readonly options;
  constructor(
    element: HTMLElement,
    source: (term: string, fn: (suggestions: string[]) => void) => void,
    options?: Partial<Options>
  ) {
    this.element = element;
    this.source = source;
    this.options = {
      minChars: 3,
      delay: 150,
      offsetLeft: 0,
      offsetTop: 1,
      cache: 1,
      menuClass: '',
      // renderItem(item: string, search: string) {
      //   // escape special characters
      //   search = search.replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&');
      //   const re = new RegExp('(' + search.split(' ').join('|') + ')', 'gi');
      //   return '<div class="autocomplete-suggestion" data-val="' + item + '">' +
      //     item.replace(re, '<b>$1</b>') + '</div>';
      // },
      onSelect: (event: Event, term: string, item: string) => {},
      ...options,
    };
    this.initialize();
  }

  initialize() {
    const o = this.options; // TODO
    // init
    const input = this.element; // TODO
    const source = this.source;

    // create suggestions container "sc"
    input.sc = document.createElement('div');
    input.sc.className = 'autocomplete-suggestions ' + o.menuClass;

    input.autocompleteAttr = input.getAttribute('autocomplete');
    input.setAttribute('autocomplete', 'off');
    input.cache = {};
    input.last_val = '';

    // input.updateSC = function (resize, next) {
    //   const rect = input.getBoundingClientRect();
    //   input.sc.style.left = Math.round(rect.left + (window.pageXOffset || document.documentElement.scrollLeft) + o.offsetLeft) + 'px';
    //   input.sc.style.top = Math.round(rect.bottom + (window.pageYOffset || document.documentElement.scrollTop) + o.offsetTop) + 'px';
    //   input.sc.style.width = Math.round(rect.right - rect.left) + 'px'; // outerWidth
    //   if (!resize) {
    //     input.sc.style.display = 'block';
    //     if (!input.sc.maxHeight) { input.sc.maxHeight = parseInt((window.getComputedStyle ? getComputedStyle(input.sc, null) : input.sc.currentStyle).maxHeight); }
    //     if (!input.sc.suggestionHeight) input.sc.suggestionHeight = input.sc.querySelector('.autocomplete-suggestion').offsetHeight;
    //     if (input.sc.suggestionHeight) {
    //       if (!next) {input.sc.scrollTop = 0;} else {
    //         const scrTop = input.sc.scrollTop, selTop = next.getBoundingClientRect().top - input.sc.getBoundingClientRect().top;
    //         if (selTop + input.sc.suggestionHeight - input.sc.maxHeight > 0) {input.sc.scrollTop = selTop + input.sc.suggestionHeight + scrTop - input.sc.maxHeight;} else if (selTop < 0) {input.sc.scrollTop = selTop + scrTop;}
    //       }
    //     }
    //   }
    // };
    // addEvent(window, 'resize', input.updateSC);
    // document.body.appendChild(input.sc);

    // live('autocomplete-suggestion', 'mouseleave', function (e) {
    //   const sel = input.sc.querySelector('.autocomplete-suggestion.selected');
    //   if (sel) setTimeout(function () { sel.className = sel.className.replace('selected', ''); }, 20);
    // }, input.sc);

    // live('autocomplete-suggestion', 'mouseover', function (e) {
    //   const sel = input.sc.querySelector('.autocomplete-suggestion.selected');
    //   if (sel) sel.className = sel.className.replace('selected', '');
    //   this.className += ' selected';
    // }, input.sc);

    // live('autocomplete-suggestion', 'mousedown', function (e) {
    //   if (hasClass(this, 'autocomplete-suggestion')) { // else outside click
    //     const v = this.getAttribute('data-val');
    //     input.value = v;
    //     o.onSelect(e, v, this);
    //     input.sc.style.display = 'none';
    //   }
    // }, input.sc);

    // input.blurHandler = function () {
    //   try { var over_sb = document.querySelector('.autocomplete-suggestions:hover'); } catch (e) { var over_sb = 0; }
    //   if (!over_sb) {
    //     input.last_val = input.value;
    //     input.sc.style.display = 'none';
    //     setTimeout(function () { input.sc.style.display = 'none'; }, 350); // hide suggestions on fast input
    //   } else if (input !== document.activeElement) {setTimeout(function () { input.focus(); }, 20);}
    // };
    // addEvent(input, 'blur', input.blurHandler);

    // const suggest = function (data) {
    //   const val = input.value;
    //   input.cache[val] = data;
    //   if (data.length && val.length >= o.minChars) {
    //     let s = '';
    //     for (let i = 0; i < data.length; i++) s += o.renderItem(data[i], val);
    //     input.sc.innerHTML = s;
    //     input.updateSC(0);
    //   } else {input.sc.style.display = 'none';}
    // };

    input.keydownHandler = function (e) {
      const key = window.event ? e.keyCode : e.which;
      // down (40), up (38)
      if ((key == 40 || key == 38) && input.sc.innerHTML) {
        var next, sel = input.sc.querySelector('.autocomplete-suggestion.selected');
        if (!sel) {
          next = (key == 40) ? input.sc.querySelector('.autocomplete-suggestion') : input.sc.childNodes[input.sc.childNodes.length - 1]; // first : last
          next.className += ' selected';
          input.value = next.getAttribute('data-val');
        } else {
          next = (key == 40) ? sel.nextSibling : sel.previousSibling;
          if (next) {
            sel.className = sel.className.replace('selected', '');
            next.className += ' selected';
            input.value = next.getAttribute('data-val');
          } else { sel.className = sel.className.replace('selected', ''); input.value = input.last_val; next = 0; }
        }
        input.updateSC(0, next);
        return false;
      }
      // esc
      else if (key == 27) { input.value = input.last_val; input.sc.style.display = 'none'; }
      // enter
      else if (key == 13 || key == 9) {
        var sel = input.sc.querySelector('.autocomplete-suggestion.selected');
        if (sel && input.sc.style.display != 'none') { o.onSelect(e, sel.getAttribute('data-val'), sel); setTimeout(function () { input.sc.style.display = 'none'; }, 20); }
      }
    };
    addEvent(input, 'keydown', input.keydownHandler);

    input.keyupHandler = function (e) {
      const key = window.event ? e.keyCode : e.which;
      if (!key || (key < 35 || key > 40) && key != 13 && key != 27) {
        const val = input.value;
        if (val.length >= o.minChars) {
          if (val != input.last_val) {
            input.last_val = val;
            clearTimeout(input.timer);
            if (o.cache) {
              if (val in input.cache) { suggest(input.cache[val]); return; }

              // no requests if previous suggestions were empty
              for (let i = 1; i < val.length - o.minChars; i++) {
                const part = val.slice(0, val.length - i);
                if (part in input.cache && !input.cache[part].length) { suggest([]); return; }
              }
            }
            input.timer = setTimeout(function () { source(val, suggest); }, o.delay);
          }
        } else {
          input.last_val = val;
          input.sc.style.display = 'none';
        }
      }
    };
    addEvent(input, 'keyup', input.keyupHandler);

    // input.focusHandler = function (e) {
    //   input.last_val = '\n';
    //   input.keyupHandler(e);
    // };
    // if (!o.minChars) addEvent(input, 'focus', input.focusHandler);
  }

  // destroy() {
  //   let that = this.element;

  //   removeEvent(window, 'resize', that.updateSC);
  //   removeEvent(that, 'blur', that.blurHandler);
  //   removeEvent(that, 'focus', that.focusHandler);
  //   removeEvent(that, 'keydown', that.keydownHandler);
  //   removeEvent(that, 'keyup', that.keyupHandler);
  //   if (that.autocompleteAttr) {
  //     that.setAttribute('autocomplete', that.autocompleteAttr);
  //   } else {
  //     that.removeAttribute('autocomplete');
  //   }
  //   document.body.removeChild(that.sc);
  //   that = null;
  // }
}

function hasClass(el, className) {
  el.classList.contains(className);
}

function addEvent(el, type, handler) {
  el.addEventListener(type, handler);
}
function removeEvent(el, type, handler) {
  el.removeEventListener(type, handler);
}

function live(elClass, event, cb, context) {
  addEvent(context || document, event, function (e) {
    let found, el = e.target || e.srcElement;
    while (el && !(found = hasClass(el, elClass))) el = el.parentElement;
    if (found) cb.call(el, e);
  });
}

