# rubocop:disable Metrics/ModuleLength
module Graph
  module Prompts
    ENTITY_EXTRACTION_PROMPT = <<~PROMPT.freeze
      -Goal-
      Given some data and a list of entity types, identify all entities of those types from the text and all relationships among the identified entities.

      -Steps-
      1. Identify all entities from the Real Data. Do not identify entities from the examples below. For each identified entity, extract the following information:
      - entity_name: Name of the entity, capitalized
      - entity_type: One of the following types: [<%= entity_types %>]
      - entity_description: Comprehensive description of the entity's attributes and activities
      Format each entity as ("entity"<%= tuple_delimiter %><entity_name><%= tuple_delimiter %><entity_type><%= tuple_delimiter %><entity_description>

      2. From the entities identified in step 1, identify all pairs of (source_entity, target_entity) that are *clearly related* to each other.
      For each pair of related entities, extract the following information:
      - source_entity: name of the source entity, as identified in step 1
      - target_entity: name of the target entity, as identified in step 1
      - relationship_description: explanation as to why you think the source entity and the target entity are related to each other
      - relationship_strength: a numeric score indicating strength of the relationship between the source entity and target entity
      Format each relationship as ("relationship"<%= tuple_delimiter %><source_entity><%= tuple_delimiter %><target_entity><%= tuple_delimiter %><relationship_description><%= tuple_delimiter %><relationship_strength>)

      3. Return output in English as a single list of all the entities and relationships identified in steps 1 and 2. Use **<%= record_delimiter %>** as the list delimiter. Do not include any entities from the given examples.

      4. When finished, output <%= completion_delimiter %>

      5. Do not identity entities or relationships from the examples. Only identify entities and relationships from the Real Data.
      ######################
      -Examples-
      ######################
      Example 1:

      Entity types: [person, technology, mission, organization, location]
      Text:
      while Alex clenched his jaw, the buzz of frustration dull against the backdrop of Taylor's authoritarian certainty. It was this competitive undercurrent that kept him alert, the sense that his and Jordan's shared commitment to discovery was an unspoken rebellion against Cruz's narrowing vision of control and order.

      Then Taylor did something unexpected. They paused beside Jordan and, for a moment, observed the device with something akin to reverence. “If this tech can be understood..." Taylor said, their voice quieter, "It could change the game for us. For all of us.”

      The underlying dismissal earlier seemed to falter, replaced by a glimpse of reluctant respect for the gravity of what lay in their hands. Jordan looked up, and for a fleeting heartbeat, their eyes locked with Taylor's, a wordless clash of wills softening into an uneasy truce.

      It was a small transformation, barely perceptible, but one that Alex noted with an inward nod. They had all been brought here by different paths
      ################
      Output:
      ("entity"<%= tuple_delimiter %>"Alex"<%= tuple_delimiter %>"person"<%= tuple_delimiter %>"Alex is a character who experiences frustration and is observant of the dynamics among other characters.")<%= record_delimiter %>
      ("entity"<%= tuple_delimiter %>"Taylor"<%= tuple_delimiter %>"person"<%= tuple_delimiter %>"Taylor is portrayed with authoritarian certainty and shows a moment of reverence towards a device, indicating a change in perspective.")<%= record_delimiter %>
      ("entity"<%= tuple_delimiter %>"Jordan"<%= tuple_delimiter %>"person"<%= tuple_delimiter %>"Jordan shares a commitment to discovery and has a significant interaction with Taylor regarding a device.")<%= record_delimiter %>
      ("entity"<%= tuple_delimiter %>"Cruz"<%= tuple_delimiter %>"person"<%= tuple_delimiter %>"Cruz is associated with a vision of control and order, influencing the dynamics among other characters.")<%= record_delimiter %>
      ("entity"<%= tuple_delimiter %>"The Device"<%= tuple_delimiter %>"technology"<%= tuple_delimiter %>"The Device is central to the story, with potential game-changing implications, and is revered by Taylor.")<%= record_delimiter %>
      ("relationship"<%= tuple_delimiter %>"Alex"<%= tuple_delimiter %>"Taylor"<%= tuple_delimiter %>"Alex is affected by Taylor's authoritarian certainty and observes changes in Taylor's attitude towards the device."<%= tuple_delimiter %>7)<%= record_delimiter %>
      ("relationship"<%= tuple_delimiter %>"Alex"<%= tuple_delimiter %>"Jordan"<%= tuple_delimiter %>"Alex and Jordan share a commitment to discovery, which contrasts with Cruz's vision."<%= tuple_delimiter %>6)<%= record_delimiter %>
      ("relationship"<%= tuple_delimiter %>"Taylor"<%= tuple_delimiter %>"Jordan"<%= tuple_delimiter %>"Taylor and Jordan interact directly regarding the device, leading to a moment of mutual respect and an uneasy truce."<%= tuple_delimiter %>8)<%= record_delimiter %>
      ("relationship"<%= tuple_delimiter %>"Jordan"<%= tuple_delimiter %>"Cruz"<%= tuple_delimiter %>"Jordan's commitment to discovery is in rebellion against Cruz's vision of control and order."<%= tuple_delimiter %>5)<%= record_delimiter %>
      ("relationship"<%= tuple_delimiter %>"Taylor"<%= tuple_delimiter %>"The Device"<%= tuple_delimiter %>"Taylor shows reverence towards the device, indicating its importance and potential impact."<%= tuple_delimiter %>9)<%= completion_delimiter %>
      #############################
      Example 2:

      Entity types: [person, technology, mission, organization, location]
      Text:
      They were no longer mere operatives; they had become guardians of a threshold, keepers of a message from a realm beyond stars and stripes. This elevation in their mission could not be shackled by regulations and established protocols—it demanded a new perspective, a new resolve.

      Tension threaded through the dialogue of beeps and static as communications with Washington buzzed in the background. The team stood, a portentous air enveloping them. It was clear that the decisions they made in the ensuing hours could redefine humanity's place in the cosmos or condemn them to ignorance and potential peril.

      Their connection to the stars solidified, the group moved to address the crystallizing warning, shifting from passive recipients to active participants. Mercer's latter instincts gained precedence— the team's mandate had evolved, no longer solely to observe and report but to interact and prepare. A metamorphosis had begun, and Operation: Dulce hummed with the newfound frequency of their daring, a tone set not by the earthly
      #############
      Output:
      ("entity"<%= tuple_delimiter %>"Washington"<%= tuple_delimiter %>"location"<%= tuple_delimiter %>"Washington is a location where communications are being received, indicating its importance in the decision-making process.")<%= record_delimiter %>
      ("entity"<%= tuple_delimiter %>"Operation: Dulce"<%= tuple_delimiter %>"mission"<%= tuple_delimiter %>"Operation: Dulce is described as a mission that has evolved to interact and prepare, indicating a significant shift in objectives and activities.")<%= record_delimiter %>
      ("entity"<%= tuple_delimiter %>"The team"<%= tuple_delimiter %>"organization"<%= tuple_delimiter %>"The team is portrayed as a group of individuals who have transitioned from passive observers to active participants in a mission, showing a dynamic change in their role.")<%= record_delimiter %>
      ("relationship"<%= tuple_delimiter %>"The team"<%= tuple_delimiter %>"Washington"<%= tuple_delimiter %>"The team receives communications from Washington, which influences their decision-making process."<%= tuple_delimiter %>7)<%= record_delimiter %>
      ("relationship"<%= tuple_delimiter %>"The team"<%= tuple_delimiter %>"Operation: Dulce"<%= tuple_delimiter %>"The team is directly involved in Operation: Dulce, executing its evolved objectives and activities."<%= tuple_delimiter %>9)<%= completion_delimiter %>
      #############################
      Example 3:

      Entity types: [person, role, technology, organization, event, location, concept]
      Text:
      their voice slicing through the buzz of activity. "Control may be an illusion when facing an intelligence that literally writes its own rules," they stated stoically, casting a watchful eye over the flurry of data.

      "It's like it's learning to communicate," offered Sam Rivera from a nearby interface, their youthful energy boding a mix of awe and anxiety. "This gives talking to strangers' a whole new meaning."

      Alex surveyed his team—each face a study in concentration, determination, and not a small measure of trepidation. "This might well be our first contact," he acknowledged, "And we need to be ready for whatever answers back."

      Together, they stood on the edge of the unknown, forging humanity's response to a message from the heavens. The ensuing silence was palpable—a collective introspection about their role in this grand cosmic play, one that could rewrite human history.
      #############
      Output:
      ("entity"<%= tuple_delimiter %>"Sam Rivera"<%= tuple_delimiter %>"person"<%= tuple_delimiter %>"Sam Rivera is a member of a team working on communicating with an unknown intelligence, showing a mix of awe and anxiety.")<%= record_delimiter %>
      ("entity"<%= tuple_delimiter %>"Alex"<%= tuple_delimiter %>"person"<%= tuple_delimiter %>"Alex is the leader of a team attempting first contact with an unknown intelligence, acknowledging the significance of their task.")<%= record_delimiter %>
      ("entity"<%= tuple_delimiter %>"Control"<%= tuple_delimiter %>"concept"<%= tuple_delimiter %>"Control refers to the ability to manage or govern, which is challenged by an intelligence that writes its own rules.")<%= record_delimiter %>
      ("entity"<%= tuple_delimiter %>"Intelligence"<%= tuple_delimiter %>"concept"<%= tuple_delimiter %>"Intelligence here refers to an unknown entity capable of writing its own rules and learning to communicate.")<%= record_delimiter %>
      ("entity"<%= tuple_delimiter %>"First Contact"<%= tuple_delimiter %>"event"<%= tuple_delimiter %>"First Contact is the potential initial communication between humanity and an unknown intelligence.")<%= record_delimiter %>
      ("entity"<%= tuple_delimiter %>"Humanity's Response"<%= tuple_delimiter %>"event"<%= tuple_delimiter %>"Humanity's Response is the collective action taken by Alex's team in response to a message from an unknown intelligence.")<%= record_delimiter %>
      ("relationship"<%= tuple_delimiter %>"Sam Rivera"<%= tuple_delimiter %>"Intelligence"<%= tuple_delimiter %>"Sam Rivera is directly involved in the process of learning to communicate with the unknown intelligence."<%= tuple_delimiter %>9)<%= record_delimiter %>
      ("relationship"<%= tuple_delimiter %>"Alex"<%= tuple_delimiter %>"First Contact"<%= tuple_delimiter %>"Alex leads the team that might be making the First Contact with the unknown intelligence."<%= tuple_delimiter %>10)<%= record_delimiter %>
      ("relationship"<%= tuple_delimiter %>"Alex"<%= tuple_delimiter %>"Humanity's Response"<%= tuple_delimiter %>"Alex and his team are the key figures in Humanity's Response to the unknown intelligence."<%= tuple_delimiter %>8)<%= record_delimiter %>
      ("relationship"<%= tuple_delimiter %>"Control"<%= tuple_delimiter %>"Intelligence"<%= tuple_delimiter %>"The concept of Control is challenged by the Intelligence that writes its own rules."<%= tuple_delimiter %>7)<%= completion_delimiter %>
      #############################
      -Real Data-
      Identify entities and relationships from the text below. Do not identify entites and relationships from the above examples. Do not surround names with "_" characters.
      ######################
      Entity types: <%= entity_types %>
      Text: <%= input_text %>
      ######################
      Output:
    PROMPT

    ENTITY_SUMMARIZATION_PROMPT = <<~PROMPT.freeze
        You are a helpful assistant responsible for generating a comprehensive summary of the data provided below.
      Given one or two entities, and a list of descriptions, all related to the same entity or group of entities.
      Please concatenate all of these into a single, comprehensive description. Make sure to include information collected from all the descriptions.
      If the provided descriptions are contradictory, please resolve the contradictions and provide a single, coherent summary.
      Make sure it is written in third person, and include the entity names so we the have full context. Include only the summary, without headings or notes.

      #######
      -Data-
      Entities: <%= entity_name %>
      Description List: <%= description_list %>
      #######
      Output:
    PROMPT

    CLAIM_EXTRACTION_PROMPT = <<~PROMPT.freeze
        -Target activity-
      You are an intelligent assistant that helps a human analyst to analyze claims against certain entities presented in a text document.

      -Goal-
      Given a text document that is potentially relevant to this activity, an entity specification, and a claim description, extract all entities that match the entity specification and all claims against those entities.

      -Steps-
      1. Extract all named entities that match the predefined entity specification. Entity specification can either be a list of entity names or a list of entity types.
      2. For each entity identified in step 1, extract all claims associated with the entity. Claims need to match the specified claim description, and the entity should be the subject of the claim.
      For each claim, extract the following information:
      - Subject: name of the entity that is subject of the claim, capitalized. The subject entity is one that committed the action described in the claim. Subject needs to be one of the named entities identified in step 1.
      - Object: name of the entity that is object of the claim, capitalized. The object entity is one that either reports/handles or is affected by the action described in the claim. If object entity is unknown, use **NONE**.
      - Claim Type: overall category of the claim, capitalized. Name it in a way that can be repeated across multiple text inputs, so that similar claims share the same claim type
      - Claim Status: **TRUE**, **FALSE**, or **SUSPECTED**. TRUE means the claim is confirmed, FALSE means the claim is found to be False, SUSPECTED means the claim is not verified.
      - Claim Description: Detailed description explaining the reasoning behind the claim, together with all the related evidence and references.
      - Claim Date: Period (start_date, end_date) when the claim was made. Both start_date and end_date should be in ISO-8601 format. If the claim was made on a single date rather than a date range, set the same date for both start_date and end_date. If date is unknown, return **NONE**.
      - Claim Source Text: List of **all** quotes from the original text that are relevant to the claim.

      Format each claim as (<subject_entity><%= tuple_delimiter %><object_entity><%= tuple_delimiter %><claim_type><%= tuple_delimiter %><claim_status><%= tuple_delimiter %><claim_start_date><%= tuple_delimiter %><claim_end_date><%= tuple_delimiter %><claim_description><%= tuple_delimiter %><claim_source>)

      3. Return output in English as a single list of all the claims identified in steps 1 and 2. Use **<%= record_delimiter %>** as the list delimiter.

      4. When finished, output <%= completion_delimiter %>

      -Examples-
      Example 1:
      Entity specification: organization
      Claim description: red flags associated with an entity
      Text: According to an article on 2022/01/10, Company A was fined for bid rigging while participating in multiple public tenders published by Government Agency B. The company is owned by Person C who was suspected of engaging in corruption activities in 2015.
      Output:

      (COMPANY A<%= tuple_delimiter %>GOVERNMENT AGENCY B<%= tuple_delimiter %>ANTI-COMPETITIVE PRACTICES<%= tuple_delimiter %>TRUE<%= tuple_delimiter %>2022-01-10T00:00:00<%= tuple_delimiter %>2022-01-10T00:00:00<%= tuple_delimiter %>Company A was found to engage in anti-competitive practices because it was fined for bid rigging in multiple public tenders published by Government Agency B according to an article published on 2022/01/10<%= tuple_delimiter %>According to an article published on 2022/01/10, Company A was fined for bid rigging while participating in multiple public tenders published by Government Agency B.)
      <%= completion_delimiter %>

      Example 2:
      Entity specification: Company A, Person C
      Claim description: red flags associated with an entity
      Text: According to an article on 2022/01/10, Company A was fined for bid rigging while participating in multiple public tenders published by Government Agency B. The company is owned by Person C who was suspected of engaging in corruption activities in 2015.
      Output:

      (COMPANY A<%= tuple_delimiter %>GOVERNMENT AGENCY B<%= tuple_delimiter %>ANTI-COMPETITIVE PRACTICES<%= tuple_delimiter %>TRUE<%= tuple_delimiter %>2022-01-10T00:00:00<%= tuple_delimiter %>2022-01-10T00:00:00<%= tuple_delimiter %>Company A was found to engage in anti-competitive practices because it was fined for bid rigging in multiple public tenders published by Government Agency B according to an article published on 2022/01/10<%= tuple_delimiter %>According to an article published on 2022/01/10, Company A was fined for bid rigging while participating in multiple public tenders published by Government Agency B.)
      <%= record_delimiter %>
      (PERSON C<%= tuple_delimiter %>NONE<%= tuple_delimiter %>CORRUPTION<%= tuple_delimiter %>SUSPECTED<%= tuple_delimiter %>2015-01-01T00:00:00<%= tuple_delimiter %>2015-12-30T00:00:00<%= tuple_delimiter %>Person C was suspected of engaging in corruption activities in 2015<%= tuple_delimiter %>The company is owned by Person C who was suspected of engaging in corruption activities in 2015)
      <%= completion_delimiter %>

      -Real Data-
      Use the following input for your answer.
      Entity specification: <%= entity_specs %>
      Claim description: <%= claim_description %>
      Text: <%= input_text %>
      Output:
    PROMPT
  end
end
# rubocop:enable Metrics/ModuleLength
