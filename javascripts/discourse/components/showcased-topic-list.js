import Component from "@ember/component";
import { action } from "@ember/object";
import { readOnly } from "@ember/object/computed";
import { getOwner } from "discourse-common/lib/get-owner";

export default Component.extend({
  moreHref: readOnly("category.url"),

  init() {
    this._super(...arguments);

    if (!this.category) {
      return;
    }

    const filter = {
      filter: "latest",
      params: {
        category: this.category.id,
      },
    };

    this.set("isLoading", true);

    this.store.findFiltered("topicList", filter).then((topicList) => {
      this.set(
        "topicList",
        topicList.topics.slice(0, settings.max_list_length)
      );

      this.set("isLoading", false);
    });
  },

  @action
  createTopic() {
    if (this.currentUser) {
      getOwner(this).lookup("controller:composer").open({
        action: "createTopic",
        draftKey: "createTopic",
        categoryId: this.category.id,
      });
    } else {
      this.router.transitionTo("login");
    }
  },
});
