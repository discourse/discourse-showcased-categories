export default {
  setupComponent() {
    if (settings.plugin_outlet === "below-site-header") {
      this.set("belowHeader", true);
    } else {
      this.set("belowHeader", false);
    }
  },
};
