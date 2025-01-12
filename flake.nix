{
  description = "Emin's Nix Templates";

  outputs = { self }: {
    templates = import ./templates.nix;
  };
}
