import Component from "@ember/component";
import { ajax } from "discourse/lib/ajax";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";
import { readOnly } from "@ember/object/computed";

export default Component.extend({
  moreHref: readOnly("category.url"),

  init() {
    this._super(...arguments);

    if (!this.category) return;

    const filter = {
      filter: "latest",
      params: {
        category: this.category.id,
      },
    };

    this.set("isLoading", true)

    this.store.findFiltered("topicList", filter).then((topicList) => {
      this.set(
        "topicList",
        topicList.topics.slice(0, settings.max_list_length)
      );

      this.set("isLoading", false)
    });
  },

  @action
  createTopic() {
    if (this.currentUser) {
      // This is not ideal - we should not be using __container__ here
      // We can't inject it properly, because ember doesn't allow injecting controllers into components
      // We can't `sendAction` up to routes/application createNewTopicViaParams because only clojure actions are allowed
      // We can't use clojure actions because then an openComposer action would have to be passed to every plugin outlet
      // The best solution is probably a core appEvent or service which themes could trigger
      Discourse.__container__.lookup("controller:composer").open({
        action: "createTopic",
        draftKey: "createTopic",
        categoryId: this.category.id,
      });
    } else {
      this.router.transitionTo("login");
    }
  },
});
