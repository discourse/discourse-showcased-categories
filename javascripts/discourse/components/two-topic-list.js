import Component from "@ember/component";
import Category from "discourse/models/category";
import discourseComputed, { observes } from "discourse-common/utils/decorators";
import { inject as service } from "@ember/service";
import { defaultHomepage } from "discourse/lib/utilities";

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
    if (!this.categoriesLoaded) {
      return false;
    }
    return Category.findById(settings.feed_one_category);
  },

  get tags1() {
    return settings.feed_one_tag.split("|").filter(tag => tag.trim() !== "");
    },

  get category2() {
    if (!this.categoriesLoaded) {
      return false;
    }
    return Category.findById(settings.feed_two_category);
  },

  get tags2() {
    return settings.feed_two_tag.split("|").filter(tag => tag.trim() !== "");
    },

  @discourseComputed("router.currentRouteName")
  shouldShow(currentRouteName) {
    let showSidebar =
      settings.show_as_sidebar && currentRouteName === "discovery.latest";
    return currentRouteName === `discovery.${defaultHomepage()}` || showSidebar;
  },

  @discourseComputed('shouldShow', 'category1', 'category2', 'tags1', 'tags2')
  showTopicLists(shouldShow, category1, category2, tags1, tags2) {
    return shouldShow && (category1 || (tags1.length > 0)) && (category2 || (tags2.length > 0));
  }
});
