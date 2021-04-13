import Component from "@ember/component";
import Category from "discourse/models/category";
import discourseComputed from "discourse-common/utils/decorators";
import { inject as service } from "@ember/service";
import { defaultHomepage } from "discourse/lib/utilities";
import { and } from "@ember/object/computed";

export default Component.extend({
  router: service(),

  get categoriesLoaded() {
    return Category.list().length !== 0;
  },

  get category1() {
    if (!this.categoriesLoaded) return false;
    return Category.findById(settings.feed_one_category);
  },

  get tag1() {
    return settings.feed_one_tag;
  },

  get category2() {
    if (!this.categoriesLoaded) return false;
    return Category.findById(settings.feed_two_category);
  },

  get tag2() {
    return settings.feed_two_tag;
  },

  @discourseComputed("router.currentRouteName")
  isHomepage(currentRouteName) {
    return currentRouteName == `discovery.${defaultHomepage()}`;
  },

  showTopicLists: and("isHomepage", "category1", "category2"),
});
