import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import didInsert from "@ember/render-modifiers/modifiers/did-insert";
import { service } from "@ember/service";
import ConditionalLoadingSpinner from "discourse/components/conditional-loading-spinner";
import DButton from "discourse/components/d-button";
import TopicList from "discourse/components/topic-list";
import Composer from "discourse/models/composer";
import i18n from "discourse-common/helpers/i18n";

export default class ShowcasedTopicList extends Component {
  @service store;
  @service composer;
  @service currentUser;
  @service router;

  @tracked isLoading = true;
  @tracked topicList;
  tags = this.args.tags.length > 0 ? this.args.tags : "";
  category = this.args.category;

  get moreHref() {
    const encodedTags = this.tags ? this.tags.join("%2C") : "";

    if (this.category && !this.tags) {
      return this.category.url + "/l/" + settings.filter;
    } else if (!this.category && this.tags) {
      return this.tags.length > 1
        ? `/search?expanded=true&q=tags%3A${encodedTags}`
        : `/tag/${this.tags[0]}/l/${settings.filter}`;
    } else if (this.category && this.tags) {
      return this.tags.length === 1
        ? `/tags/c/${this.category.slug}/${this.category.id}/${this.tags[0]}/l/${settings.filter}`
        : `/search?expanded=true&q=%23${this.category.slug} tags%3A${encodedTags}`;
    } else {
      return "";
    }
  }

  @action
  async getTopics() {
    if (!this.category && !this.tags) {
      return;
    }

    const filter = {
      filter: settings.filter,
      params: {
        category: this.category?.id,
        tags: this.tags,
      },
    };

    try {
      const topicList = await this.store.findFiltered("topicList", filter);
      this.topicList = topicList.topics.slice(0, settings.max_list_length);
    } catch (error) {
      // eslint-disable-next-line no-console
      console.error("Error getting topics:", error);
    } finally {
      this.isLoading = false;
    }
  }

  @action
  createTopic() {
    if (this.currentUser) {
      this.composer.open({
        action: Composer.CREATE_TOPIC,
        draftKey: Composer.NEW_TOPIC_KEY,
        categoryId: this.category?.id,
        tags: this.tags,
      });
    } else {
      this.router.transitionTo("login");
    }
  }

  <template>
    <div class="header-wrapper" {{didInsert this.getTopics}}>
      <a href={{this.moreHref}}><h2>{{@title}}</h2></a>
      <DButton
        @action={{this.createTopic}}
        @translatedLabel={{i18n (themePrefix "showcased_categories.new_post")}}
        class="btn-primary btn"
      />
    </div>

    <ConditionalLoadingSpinner @condition={{this.isLoading}}>
      <TopicList @topics={{this.topicList}} @showPosters="false" />
    </ConditionalLoadingSpinner>

    <a href={{this.moreHref}} class="btn btn-more">
      {{i18n (themePrefix "showcased_categories.view_more")}}
    </a>
  </template>
}
