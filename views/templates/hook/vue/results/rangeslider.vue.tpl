{capture name="template"}{include file=ElasticSearch::tpl('hook/vue/results/rangeslider.html.tpl')}{/capture}
<script type="text/javascript">
  {literal}
  (function () {
    Vue.component('range-slider', {
      delimiters: ['%%', '%%'],
      template: '{/literal}{$smarty.capture.template|escape:'javascript':'UTF-8'}{literal}',
      data: function data() {
        return {
          flag: false,
          size: 0,
          currentValue: 0,
          currentSlider: 0
        };
      },

      props: {
        width: {
          type: [Number, String],
          default: 'auto'
        },
        height: {
          type: [Number, String],
          default: 6
        },
        data: {
          type: Array,
          default: null
        },
        dotSize: {
          type: Number,
          default: 16
        },
        dotWidth: {
          type: Number,
          required: false
        },
        dotHeight: {
          type: Number,
          required: false
        },
        min: {
          type: Number,
          default: 0
        },
        max: {
          type: Number,
          default: 100
        },
        interval: {
          type: Number,
          default: 1
        },
        show: {
          type: Boolean,
          default: true
        },
        disabled: {
          type: Boolean,
          default: false
        },
        piecewise: {
          type: Boolean,
          default: false
        },
        tooltip: {
          type: [String, Boolean],
          default: 'always'
        },
        eventType: {
          type: String,
          default: 'auto'
        },
        direction: {
          type: String,
          default: 'horizontal'
        },
        reverse: {
          type: Boolean,
          default: false
        },
        lazy: {
          type: Boolean,
          default: false
        },
        clickable: {
          type: Boolean,
          default: true
        },
        speed: {
          type: Number,
          default: 0.5
        },
        realTime: {
          type: Boolean,
          default: false
        },
        stopPropagation: {
          type: Boolean,
          default: false
        },
        value: {
          type: [String, Number, Array],
          default: 0
        },
        piecewiseLabel: {
          type: Boolean,
          default: false
        },
        sliderStyle: [Array, Object],
        tooltipDir: [Array, String],
        formatter: [String, Function],
        piecewiseStyle: Object,
        piecewiseActiveStyle: Object,
        processStyle: Object,
        bgStyle: Object,
        tooltipStyle: [Array, Object],
        labelStyle: Object,
        labelActiveStyle: Object
      },
      computed: {
        dotWidthVal: function dotWidthVal() {
          return typeof this.dotWidth === 'number' ? this.dotWidth : this.dotSize;
        },
        dotHeightVal: function dotHeightVal() {
          return typeof this.dotHeight === 'number' ? this.dotHeight : this.dotSize;
        },
        flowDirection: function flowDirection() {
          return 'vue-slider-' + (this.direction + (this.reverse ? '-reverse' : ''));
        },
        tooltipDirection: function tooltipDirection() {
          var dir = this.tooltipDir || (this.direction === 'vertical' ? 'left' : 'top');
          if (Array.isArray(dir)) {
            return this.isRange ? dir : dir[1];
          } else {
            return this.isRange ? [dir, dir] : dir;
          }
        },
        tooltipStatus: function tooltipStatus() {
          return this.tooltip === 'hover' && this.flag ? 'vue-slider-always' : this.tooltip ? 'vue-slider-' + this.tooltip : '';
        },
        tooltipClass: function tooltipClass() {
          return ['vue-slider-tooltip-' + this.tooltipDirection, 'vue-slider-tooltip'];
        },
        isDisabled: function isDisabled() {
          return this.eventType === 'none' ? true : this.disabled;
        },
        disabledClass: function disabledClass() {
          return this.disabled ? 'vue-slider-disabled' : '';
        },
        isRange: function isRange() {
          return Array.isArray(this.value);
        },
        slider: function slider() {
          return this.isRange ? [this.$refs.dot0, this.$refs.dot1] : this.$refs.dot;
        },
        minimum: function minimum() {
          return this.data ? 0 : this.min;
        },

        val: {
          get: function get() {
            return this.data ? this.isRange ? [this.data[this.currentValue[0]], this.data[this.currentValue[1]]] : this.data[this.currentValue] : this.currentValue;
          },
          set: function set(val) {
            if (this.data) {
              if (this.isRange) {
                var index0 = this.data.indexOf(val[0]);
                var index1 = this.data.indexOf(val[1]);
                if (index0 > -1 && index1 > -1) {
                  this.currentValue = [index0, index1];
                }
              } else {
                var index = this.data.indexOf(val);
                if (index > -1) {
                  this.currentValue = index;
                }
              }
            } else {
              this.currentValue = val;
            }
          }
        },
        currentIndex: function currentIndex() {
          if (this.isRange) {
            return this.data ? this.currentValue : [(this.currentValue[0] - this.minimum) / this.spacing, (this.currentValue[1] - this.minimum) / this.spacing];
          } else {
            return (this.currentValue - this.minimum) / this.spacing;
          }
        },
        indexRange: function indexRange() {
          if (this.isRange) {
            return this.currentIndex;
          } else {
            return [0, this.currentIndex];
          }
        },
        maximum: function maximum() {
          return this.data ? this.data.length - 1 : this.max;
        },
        multiple: function multiple() {
          var decimals = ('' + this.interval).split('.')[1];
          return decimals ? Math.pow(10, decimals.length) : 1;
        },
        spacing: function spacing() {
          return this.data ? 1 : this.interval;
        },
        total: function total() {
          if (this.data) {
            return this.data.length - 1;
          } else if (~~((this.maximum - this.minimum) * this.multiple) % (this.interval * this.multiple) !== 0) {
            console.error('[Vue-slider warn]: Prop[interval] is illegal, Please make sure that the interval can be divisible');
          }
          return (this.maximum - this.minimum) / this.interval;
        },
        gap: function gap() {
          return this.size / this.total;
        },
        position: function position() {
          return this.isRange ? [(this.currentValue[0] - this.minimum) / this.spacing * this.gap, (this.currentValue[1] - this.minimum) / this.spacing * this.gap] : (this.currentValue - this.minimum) / this.spacing * this.gap;
        },
        limit: function limit() {
          return this.isRange ? [[0, this.position[1]], [this.position[0], this.size]] : [0, this.size];
        },
        valueLimit: function valueLimit() {
          return this.isRange ? [[this.minimum, this.currentValue[1]], [this.currentValue[0], this.maximum]] : [this.minimum, this.maximum];
        },
        wrapStyles: function wrapStyles() {
          return this.direction === 'vertical' ? {
            height: typeof this.height === 'number' ? this.height + 'px' : this.height,
            padding: this.dotHeightVal / 2 + 'px ' + this.dotWidthVal / 2 + 'px'
          } : {
            width: typeof this.width === 'number' ? this.width + 'px' : this.width,
            padding: this.dotHeightVal / 2 + 'px ' + this.dotWidthVal / 2 + 'px'
          };
        },
        sliderStyles: function sliderStyles() {
          if (Array.isArray(this.sliderStyle)) {
            return this.isRange ? this.sliderStyle : this.sliderStyle[1];
          } else {
            return this.isRange ? [this.sliderStyle, this.sliderStyle] : this.sliderStyle;
          }
        },
        tooltipStyles: function tooltipStyles() {
          if (Array.isArray(this.tooltipStyle)) {
            return this.isRange ? this.tooltipStyle : this.tooltipStyle[1];
          } else {
            return this.isRange ? [this.tooltipStyle, this.tooltipStyle] : this.tooltipStyle;
          }
        },
        elemStyles: function elemStyles() {
          return this.direction === 'vertical' ? {
            width: this.width + 'px',
            height: '100%'
          } : {
            height: this.height + 'px'
          };
        },
        dotStyles: function dotStyles() {
          return this.direction === 'vertical' ? {
            width: this.dotWidthVal + 'px',
            height: this.dotHeightVal + 'px',
            left: -(this.dotWidthVal - this.width) / 2 + 'px'
          } : {
            width: this.dotWidthVal + 'px',
            height: this.dotHeightVal + 'px',
            top: -(this.dotHeightVal - this.height) / 2 + 'px'
          };
        },
        piecewiseDotStyle: function piecewiseDotStyle() {
          return this.direction === 'vertical' ? {
            width: this.width + 'px',
            height: this.width + 'px'
          } : {
            width: this.height + 'px',
            height: this.height + 'px'
          };
        },
        piecewiseDotWrap: function piecewiseDotWrap() {
          if (!this.piecewise && !this.piecewiseLabel) {
            return false;
          }
          var arr = [];
          for (var i = 0; i <= this.total; i++) {
            var style = this.direction === 'vertical' ? {
              bottom: this.gap * i - this.width / 2 + 'px',
              left: 0
            } : {
              left: this.gap * i - this.height / 2 + 'px',
              top: 0
            };
            var index = this.reverse ? this.total - i : i;
            var label = this.data ? this.data[index] : this.spacing * index + this.min;
            arr.push({
              style: style,
              label: this.formatter ? this.formatting(label) : label,
              inRange: index >= this.indexRange[0] && index <= this.indexRange[1]
            });
          }
          return arr;
        }
      },
      watch: {
        value: function value(val) {
          this.flag || this.setValue(val, true);
        },
        max: function max(val) {
          var resetVal = this.limitValue(this.val);
          resetVal !== false && this.setValue(resetVal);
          this.refresh();
        },
        min: function min(val) {
          var resetVal = this.limitValue(this.val);
          resetVal !== false && this.setValue(resetVal);
          this.refresh();
        },
        show: function show(bool) {
          var _this = this;

          if (bool && !this.size) {
            this.$nextTick(function () {
              _this.refresh();
            });
          }
        }
      },
      methods: {
        bindEvents: function bindEvents() {
          document.addEventListener('touchmove', this.moving, { passive: false });
          document.addEventListener('touchend', this.moveEnd, { passive: false });
          document.addEventListener('mousemove', this.moving);
          document.addEventListener('mouseup', this.moveEnd);
          document.addEventListener('mouseleave', this.moveEnd);
          window.addEventListener('resize', this.refresh);
        },
        unbindEvents: function unbindEvents() {
          window.removeEventListener('resize', this.refresh);
          document.removeEventListener('touchmove', this.moving);
          document.removeEventListener('touchend', this.moveEnd);
          document.removeEventListener('mousemove', this.moving);
          document.removeEventListener('mouseup', this.moveEnd);
          document.removeEventListener('mouseleave', this.moveEnd);
        },
        formatting: function formatting(value) {
          return typeof this.formatter === 'string' ? this.formatter.replace(/\{value\}/, value) : this.formatter(value);
        },
        getPos: function getPos(e) {
          this.realTime && this.getStaticData();
          return this.direction === 'vertical' ? this.reverse ? e.pageY - this.offset : this.size - (e.pageY - this.offset) : this.reverse ? this.size - (e.clientX - this.offset) : e.clientX - this.offset;
        },
        wrapClick: function wrapClick(e) {
          if (this.isDisabled || !this.clickable) return false;
          var pos = this.getPos(e);
          if (this.isRange) {
            this.currentSlider = pos > (this.position[1] - this.position[0]) / 2 + this.position[0] ? 1 : 0;
          }
          this.setValueOnPos(pos);
        },
        moveStart: function moveStart(e, index) {
          if (this.stopPropagation) {
            e.stopPropagation();
          }
          if (this.isDisabled) return false;else if (this.isRange) {
            this.currentSlider = index;
          }
          this.flag = true;
          this.$emit('drag-start', this);
        },
        moving: function moving(e) {
          if (this.stopPropagation) {
            e.stopPropagation();
          }
          if (!this.flag) return false;
          e.preventDefault();
          if (e.targetTouches && e.targetTouches[0]) e = e.targetTouches[0];
          this.setValueOnPos(this.getPos(e), true);
        },
        moveEnd: function moveEnd(e) {
          if (this.stopPropagation) {
            e.stopPropagation();
          }
          if (this.flag) {
            this.$emit('drag-end', this);
            if (this.lazy && this.isDiff(this.val, this.value)) {
              this.syncValue();
            }
          } else {
            return false;
          }
          this.flag = false;
          this.setPosition();
        },
        setValueOnPos: function setValueOnPos(pos, isDrag) {
          var range = this.isRange ? this.limit[this.currentSlider] : this.limit;
          var valueRange = this.isRange ? this.valueLimit[this.currentSlider] : this.valueLimit;
          if (pos >= range[0] && pos <= range[1]) {
            this.setTransform(pos);
            var v = (Math.round(pos / this.gap) * (this.spacing * this.multiple) + this.minimum * this.multiple) / this.multiple;
            this.setCurrentValue(v, isDrag);
          } else if (pos < range[0]) {
            this.setTransform(range[0]);
            this.setCurrentValue(valueRange[0]);
            if (this.currentSlider === 1) this.currentSlider = 0;
          } else {
            this.setTransform(range[1]);
            this.setCurrentValue(valueRange[1]);
            if (this.currentSlider === 0) this.currentSlider = 1;
          }
        },
        isDiff: function isDiff(a, b) {
          if (Object.prototype.toString.call(a) !== Object.prototype.toString.call(b)) {
            return true;
          } else if (Array.isArray(a) && a.length === b.length) {
            return a.some(function (v, i) {
              return v !== b[i];
            });
          }
          return a !== b;
        },
        setCurrentValue: function setCurrentValue(val, bool) {
          if (val < this.minimum || val > this.maximum) return false;
          if (this.isRange) {
            if (this.isDiff(this.currentValue[this.currentSlider], val)) {
              this.currentValue.splice(this.currentSlider, 1, val);
              if (!this.lazy || !this.flag) {
                this.syncValue();
              }
            }
          } else if (this.isDiff(this.currentValue, val)) {
            this.currentValue = val;
            if (!this.lazy || !this.flag) {
              this.syncValue();
            }
          }
          bool || this.setPosition();
        },
        setIndex: function setIndex(val) {
          if (Array.isArray(val) && this.isRange) {
            var value = void 0;
            if (this.data) {
              value = [this.data[val[0]], this.data[val[1]]];
            } else {
              value = [this.spacing * val[0] + this.minimum, this.spacing * val[1] + this.minimum];
            }
            this.setValue(value);
          } else {
            val = this.spacing * val + this.minimum;
            if (this.isRange) {
              this.currentSlider = val > (this.currentValue[1] - this.currentValue[0]) / 2 + this.currentValue[0] ? 1 : 0;
            }
            this.setCurrentValue(val);
          }
        },
        setValue: function setValue(val, noCb, speed) {
          var _this2 = this;

          if (this.isDiff(this.val, val)) {
            var resetVal = this.limitValue(val);
            if (resetVal !== false) {
              this.val = this.isRange ? resetVal.concat() : resetVal;
            } else {
              this.val = this.isRange ? val.concat() : val;
            }
            this.syncValue(noCb);
          }
          this.$nextTick(function () {
            return _this2.setPosition(speed);
          });
        },
        setPosition: function setPosition(speed) {
          this.flag || this.setTransitionTime(speed === undefined ? this.speed : speed);
          if (this.isRange) {
            this.currentSlider = 0;
            this.setTransform(this.position[this.currentSlider]);
            this.currentSlider = 1;
            this.setTransform(this.position[this.currentSlider]);
          } else {
            this.setTransform(this.position);
          }
          this.flag || this.setTransitionTime(0);
        },
        setTransform: function setTransform(val) {
          var value = (this.direction === 'vertical' ? this.dotHeightVal / 2 - val : val - this.dotWidthVal / 2) * (this.reverse ? -1 : 1);
          var translateValue = this.direction === 'vertical' ? 'translateY(' + value + 'px)' : 'translateX(' + value + 'px)';
          var processSize = (this.currentSlider === 0 ? this.position[1] - val : val - this.position[0]) + 'px';
          var processPos = (this.currentSlider === 0 ? val : this.position[0]) + 'px';
          if (this.isRange) {
            this.slider[this.currentSlider].style.transform = translateValue;
            this.slider[this.currentSlider].style.WebkitTransform = translateValue;
            this.slider[this.currentSlider].style.msTransform = translateValue;
            if (this.direction === 'vertical') {
              this.$refs.process.style.height = processSize;
              this.$refs.process.style[this.reverse ? 'top' : 'bottom'] = processPos;
            } else {
              this.$refs.process.style.width = processSize;
              this.$refs.process.style[this.reverse ? 'right' : 'left'] = processPos;
            }
          } else {
            this.slider.style.transform = translateValue;
            this.slider.style.WebkitTransform = translateValue;
            this.slider.style.msTransform = translateValue;
            if (this.direction === 'vertical') {
              this.$refs.process.style.height = val + 'px';
              this.$refs.process.style[this.reverse ? 'top' : 'bottom'] = 0;
            } else {
              this.$refs.process.style.width = val + 'px';
              this.$refs.process.style[this.reverse ? 'right' : 'left'] = 0;
            }
          }
        },
        setTransitionTime: function setTransitionTime(time) {
          time || this.$refs.process.offsetWidth;
          if (this.isRange) {
            for (var i = 0; i < this.slider.length; i++) {
              this.slider[i].style.transitionDuration = time + 's';
              this.slider[i].style.WebkitTransitionDuration = time + 's';
            }
            this.$refs.process.style.transitionDuration = time + 's';
            this.$refs.process.style.WebkitTransitionDuration = time + 's';
          } else {
            this.slider.style.transitionDuration = time + 's';
            this.slider.style.WebkitTransitionDuration = time + 's';
            this.$refs.process.style.transitionDuration = time + 's';
            this.$refs.process.style.WebkitTransitionDuration = time + 's';
          }
        },
        limitValue: function limitValue(val) {
          var _this3 = this;

          if (this.data) {
            return val;
          }
          var bool = false;
          if (this.isRange) {
            val = val.map(function (v) {
              if (v < _this3.min) {
                bool = true;
                return _this3.min;
              } else if (v > _this3.max) {
                bool = true;
                return _this3.max;
              }
              return v;
            });
          } else if (val > this.max) {
            bool = true;
            val = this.max;
          } else if (val < this.min) {
            bool = true;
            val = this.min;
          }
          return bool && val;
        },
        syncValue: function syncValue(noCb) {
          noCb || this.$emit('callback', this.val);
          this.$emit('input', this.isRange ? this.val.concat() : this.val);
        },
        getValue: function getValue() {
          return this.val;
        },
        getIndex: function getIndex() {
          return this.currentIndex;
        },
        getStaticData: function getStaticData() {
          if (this.$refs.elem) {
            this.size = this.direction === 'vertical' ? this.$refs.elem.offsetHeight : this.$refs.elem.offsetWidth;
            this.offset = this.direction === 'vertical' ? this.$refs.elem.getBoundingClientRect().top + window.pageYOffset || document.documentElement.scrollTop : this.$refs.elem.getBoundingClientRect().left;
          }
        },
        refresh: function refresh() {
          if (this.$refs.elem) {
            this.getStaticData();
            this.setPosition();
          }
        }
      },
      mounted: function mounted() {
        var _this4 = this;

        if (typeof window === 'undefined' || typeof document === 'undefined') return;
        this.$nextTick(function () {
          _this4.getStaticData();
          _this4.setValue(_this4.value, true, 0);
          _this4.bindEvents();
        });
      },
      beforeDestroy: function beforeDestroy() {
        this.unbindEvents();
      }
    });
  }());
  {/literal}
</script>
