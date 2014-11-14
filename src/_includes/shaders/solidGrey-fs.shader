<script id='solidGrey-fs' type="x-shader/x-fragment">
  precision mediump float;
  uniform vec4 uColor;
  
  void main(void) {
    //vec4(0.8087, 0.7764, 0.8169, 1.0);
    gl_FragColor = uColor;
  }
</script>