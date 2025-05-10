{
  programs.helix = {
    enable = true;
    defaultEditor = true;
    settings = {
      editor = {
        line-number = "relative";
        cursor-shape = {
          insert = "bar";
        };
      };
      keys.normal = {
        space.space = "file_picker";
        C.s = ":w";
        space.q = ":q";
      };
    };
  };
}
