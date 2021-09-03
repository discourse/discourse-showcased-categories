import Component from "@ember/component";
import Category from "discourse/models/category";
import discourseComputed, { observes } from "discourse-common/utils/decorators";
import { inject as service } from "@ember/service";
import { defaultHomepage } from "discourse/lib/utilities";
import { and } from "@ember/object/computed";

export default Component.extend({
  router: service(),
  tagName: "",

  didInsertElement() {
    this._super(...arguments);
    this._updateBodyClasses();
  },
  willDestroyElement() {
    this._super(...arguments);
    this._updateBodyClasses();
  },

  @observes("shouldShow")
  _updateBodyClasses() {
    const shouldCleanup = this.isDestroying || this.isDestroyed;
    if (!shouldCleanup && this.shouldShow && settings.show_as_sidebar) {
      document.body.classList.add("showcased-categories-sidebar");
    } else {
      document.body.classList.remove("showcased-categories-sidebar");
    }
  },

  get categoriesLoaded() {
    return Category.list().length !== 0;
  },

  get category1() {
    if (!this.categoriesLoaded) return false;
    return Category.findById(settings.feed_one_category);
  },

  get category2() {
    if (!this.categoriesLoaded) return false;
    return Category.findById(settings.feed_two_category);
  },

  @discourseComputed("router.currentRouteName")
  shouldShow(currentRouteName) {
    let showSidebar =
      settings.show_as_sidebar && currentRouteName === "discovery.latest";
    return currentRouteName === `discovery.${defaultHomepage()}` || showSidebar;
  },

  showTopicLists: and("shouldShow", "category1", "category2")
});
