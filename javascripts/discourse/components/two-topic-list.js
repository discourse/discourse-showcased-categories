import Component from "@ember/component";
import { ajax } from "discourse/lib/ajax";
import Topic from 'discourse/models/topic';
import { action } from "@ember/object";
import Category from "discourse/models/category";
import discourseComputed from "discourse-common/utils/decorators";
import { inject as service } from "@ember/service";

export default Component.extend({
  topicListOne: null,
  topicListTwo: null,
  router: service(),

  init() {
    this._super(...arguments);
    
    if (Category.list().length == 0) return false;

    let categoryOne = Category.findById(settings.feed_one_category);
    let hrefOne = 'c/';

    if (!categoryOne) return false;

    if (categoryOne.parentCategory) {
      hrefOne += categoryOne.parentCategory.slug + "/" + categoryOne.slug + ".json";
    } else {
      hrefOne += categoryOne.slug + ".json";
    }

    ajax(hrefOne).then((result) => {
      let topicList = [];
      result.topic_list.topics.slice(0,settings.max_list_length).forEach((topic) => {
        topic.posters.forEach((poster) => {
          poster.user = $.grep(user, (e) => {
            return e.id == poster.user_id;
          })[0];
        });
        topicList.push(Topic.create(topic));
      });
      if (topicList.length !== 0) {
        this.set("topicListOne", topicList);
      }
    });

    let categoryTwo = Category.findById(settings.feed_two_category);
    let hrefTwo = 'c/';

    if (!categoryTwo) return false;

    if (categoryTwo.parentCategory) {
      hrefTwo += categoryTwo.parentCategory.slug + "/" + categoryTwo.slug + ".json";
    } else {
      hrefTwo += categoryTwo.slug + ".json";
    }

    ajax(hrefTwo).then((result) => {
      let topicList = [];
      result.topic_list.topics.slice(0,settings.max_list_length).forEach((topic) => {
        topic.posters.forEach((poster) => {
          poster.user = $.grep(user, (e) => {
            return e.id == poster.user_id;
          })[0];
        });
        topicList.push(Topic.create(topic));
      });
      if (topicList.length !== 0) {
        this.set("topicListTwo", topicList);
      }
    });

  },

  @discourseComputed()
  topicListOneHref() {
    if (Category.list().length == 0) return false;

    let category = Category.findById(settings.feed_one_category);

    if (category) {
      if (category.parentCategory) {
        let parent = Category.findById(category.parentCategory.id)
        return parent.slug + "/" + category.slug;
      } else {
        return category.slug;
      }
    }
  },

  @discourseComputed()
  topicListTwoHref() {
    if (Category.list().length == 0) return false;

    let category = Category.findById(settings.feed_two_category);

    if (category) {
      if (category.parentCategory) {
        let parent = Category.findById(category.parentCategory.id)
        return parent.slug + "/" + category.slug;
      } else {
        return category.slug;
      }
    }
  },

  @discourseComputed("router.currentURL")
  showTopicLists(currentURL) {
    if (settings.feed_one_category && settings.feed_two_category && Category.list().length !== 0) {
      return currentURL.split("?") === "/";
    } else {
      return false;
    }
  },

  @action
  createListOneTopic() {
    if (Discourse.User.current()) {
      Discourse.__container__.lookup('controller:composer')
      .open({
        action: "createTopic", 
        draftKey: "createTopic", 
        categoryId: settings.feed_one_category
      });
    } else {
      return window.location = getURL("/signup");
    }
  },

  @action
  createListTwoTopic() {
    if (Discourse.User.current()) {
      Discourse.__container__.lookup('controller:composer')
      .open({
        action: "createTopic", 
        draftKey: "createTopic", 
        categoryId: settings.feed_two_category
      });
    } else {
      return window.location = getURL("/signup");
    }
  }
})