import time
import uuid
import oci
from oci.data_integration.data_integration_client import DataIntegrationClient
from oci.data_integration.models.composite_field_map import CompositeFieldMap
from oci.data_integration.models.config_values import ConfigValues
from oci.data_integration.models.config_parameter_value import ConfigParameterValue
from oci.data_integration.models.create_data_flow_details import CreateDataFlowDetails
from oci.data_integration.models.data_entity_from_table import DataEntityFromTable
from oci.data_integration.models.dynamic_input_field import DynamicInputField
from oci.data_integration.models.dynamic_type import DynamicType
from oci.data_integration.models.flow_node import FlowNode
from oci.data_integration.models.input_link import InputLink
from oci.data_integration.models.input_port import InputPort
from oci.data_integration.models.name_list_rule import NameListRule
from oci.data_integration.models.type_list_rule import TypeListRule
from oci.data_integration.models.name_pattern_rule import NamePatternRule
from oci.data_integration.models.output_link import OutputLink
from oci.data_integration.models.output_port import OutputPort
from oci.data_integration.models.proxy_field import ProxyField
from oci.data_integration.models.dynamic_proxy_field import DynamicProxyField
from oci.data_integration.models.read_operation_config import ReadOperationConfig
from oci.data_integration.models.registry_metadata import RegistryMetadata
from oci.data_integration.models.rule_based_field_map import RuleBasedFieldMap
from oci.data_integration.models.direct_field_map import DirectFieldMap
from oci.data_integration.models.rule_type_config import RuleTypeConfig
from oci.data_integration.models.source import Source
from oci.data_integration.models.target import Target
from oci.data_integration.models.filter import Filter
from oci.data_integration.models.aggregator import Aggregator
from oci.data_integration.models.joiner import Joiner
from oci.data_integration.models.projection import Projection
from oci.data_integration.models.expression import Expression
from oci.data_integration.models.derived_field import DerivedField
from oci.data_integration.models.schema import Schema
from oci.data_integration.models.parameter import Parameter
from oci.data_integration.models.data_asset import DataAsset
from oci.data_integration.models.connection import Connection
from oci.data_integration.models.root_object import RootObject
from oci.data_integration.models.ui_properties import UIProperties
from oci.data_integration.models.write_operation_config import WriteOperationConfig
from oci.data_integration.models.oracle_write_attribute import OracleWriteAttribute

def get_uuid():
    return str(uuid.uuid4())
def get_time_in_millis_str():
    return str(round(time.time() * 1000))

def _create_config_values(dataAsset,connection, schema, dataAssetType, connectionType, parameterRefs, keys):
    schema = Schema(model_type="SCHEMA", key='dataref:'+connection+'/'+schema,object_status=1)
    con = RootObject(model_type=connectionType, key=connection, object_status=1)
    dataasset = RootObject(model_type=dataAssetType, key=dataAsset, object_status=1)
    configValuesMap = {'connectionParam': ConfigParameterValue(ref_value=con),
      'dataAssetParam': ConfigParameterValue(ref_value=dataasset),
      'schemaParam': ConfigParameterValue(ref_value=schema)}

    if (parameterRefs is not None) :
      for paramRef in parameterRefs:
        entityParam=paramRef.get("entity")
        dataAssetParam=paramRef.get("dataAsset")
        connectionParam=paramRef.get("connection")
        schemaParam=paramRef.get("schema")
        if (dataAssetParam is not None):
          configValuesMap.update([("dataAssetParam", {"parameterValue": keys[dataAssetParam]})])
        elif (connectionParam is not None):
          configValuesMap.update([("connectionParam", {"parameterValue": keys[connectionParam]})])
        elif (schemaParam is not None):
          configValuesMap.update([("schemaParam", {"parameterValue": keys[schemaParam]})])
        elif (entityParam is not None):
          configValuesMap.update([("dataEntityParam", {"parameterValue": keys[entityParam]})])

    default_config = ConfigValues(config_param_values=configValuesMap)
    return default_config

def _create_dynamic_input_field(dif_name, difkey):
    name_pattern_rule = NamePatternRule(matching_strategy=NamePatternRule.MATCHING_STRATEGY_NAME_ONLY,
                                        rule_type=NamePatternRule.RULE_TYPE_INCLUDE,pattern=".*")
    rule_type_config = RuleTypeConfig(projection_rules=[name_pattern_rule])
    dynamic_type = DynamicType(type_handler=rule_type_config)
    return DynamicInputField(key = difkey, name=dif_name, type=dynamic_type)

def _create_dynamic_proxy_field(dpf_name, dpfkey, node_info, scope, property):
    name_pattern_rule = NamePatternRule(matching_strategy=NamePatternRule.MATCHING_STRATEGY_NAME_ONLY,
                                        rule_type=NamePatternRule.RULE_TYPE_INCLUDE,pattern=".*")
    rules=[]
    projectionRules=node_info.get(property)
    if (projectionRules is not None):
      for projectionRule in projectionRules:
        if (projectionRule.get("matchType") == "NAME_LIST"):
          ruleType=NameListRule.RULE_TYPE_INCLUDE
          match=NameListRule.MATCHING_STRATEGY_NAME_ONLY
          if (projectionRule.get("ruleType") == "EXCLUDE"):
            ruleType=NameListRule.RULE_TYPE_EXCLUDE
          namelist=projectionRule.get("value")
          name_list_rule = NameListRule(matching_strategy=match,rule_type=ruleType,names=namelist)
          rules.append(name_list_rule)
        elif (projectionRule.get("matchType") == "TYPE_LIST"):
          ruleType=TypeListRule.RULE_TYPE_INCLUDE
          match=TypeListRule.MATCHING_STRATEGY_NAME_ONLY
          if (projectionRule.get("ruleType") == "EXCLUDE"):
            ruleType=TypeListRule.RULE_TYPE_EXCLUDE
          #typelist=projectionRule.get("value")
          typelist=[{"modelType":"DATA_TYPE", "key":"Seeded:/typeSystems/PLATFORM/dataTypes/VARCHAR", "objectStatus":1,"typeSystemName":"Platform"}]
          type_list_rule = TypeListRule(matching_strategy=match,rule_type=ruleType,types=typelist)
          rules.append(type_list_rule)
        else:
          ruleType=NamePatternRule.RULE_TYPE_INCLUDE
          match=NamePatternRule.MATCHING_STRATEGY_NAME_ONLY
          if (projectionRule.get("ruleType") == "EXCLUDE"):
            ruleType=NamePatternRule.RULE_TYPE_EXCLUDE
          pattern=projectionRule.get("value")
          name_pattern_rule = NamePatternRule(matching_strategy=match,rule_type=ruleType,pattern=pattern)
          rules.append(name_pattern_rule)
    if (len(rules) == 0):
      rules.append(name_pattern_rule)

    rule_type_config = RuleTypeConfig(projection_rules=rules, scope=scope)
    dynamic_type = DynamicType(type_handler=rule_type_config)
    return DynamicProxyField(key = dpfkey, name=dpf_name, type=dynamic_type)

def _create_proxyfield(pxyname, scopeop):
    return ProxyField(name=pxyname, scope=scopeop)


def create_parameter(key, keys,node_info):
  # check if its a data asset, connection, schema, entity etc.Does the property entity need to change?
  if node_info.get("entity") is not None:
    type="com.oracle.dicom.model.entity.AbstractDataEntity"
    return Parameter(name=key, description=node_info["description"], key=keys[key], root_object_default_value={"modelType": "ENRICHED_ENTITY", "entity": node_info["entity"], "object_status":1},type={"modelType":"JAVA_TYPE", "javaTypeName":type}, type_name=type)
  elif node_info.get("dataAsset") is not None:
    type="com.oracle.dicom.model.dataasset.AbstractDataAsset"
    return Parameter(name=key, description=node_info["description"], key=keys[key], root_object_default_value=node_info["dataAsset"],type={"modelType":"JAVA_TYPE", "javaTypeName":type}, type_name=type)
  elif node_info.get("connection") is not None:
    type="com.oracle.dicom.model.connection.AbstractConnection"
    return Parameter(name=key, description=node_info["description"], key=keys[key], root_object_default_value=node_info["connection"],type={"modelType":"JAVA_TYPE", "javaTypeName":type}, type_name=type)
  elif node_info.get("schema") is not None:
    type="com.oracle.dicom.model.schema.Schema"
    return Parameter(name=key, description=node_info["description"], key=keys[key], root_object_default_value=node_info["schema"],type={"modelType":"JAVA_TYPE", "javaTypeName":type}, type_name=type)
  elif node_info.get("joinCondition") is not None:
    type="com.oracle.dicom.model.expression.Expression"
    return Parameter(name=key, description=node_info["description"], key=keys[key], default_value=node_info.get("joinCondition"),type={"modelType":"JAVA_TYPE", "javaTypeName":type})
  elif node_info.get("filterCondition") is not None:
    type="com.oracle.dicom.model.expression.Expression"
    return Parameter(name=key, description=node_info["description"], key=keys[key], default_value=node_info.get("filterCondition"),type={"modelType":"JAVA_TYPE", "javaTypeName":type})

def create_source(di_client, workspace_id, key, keys, node_info):
    #Source Output Port
    src_entity = node_info["connection"]+'/'+node_info["schema"]+'/'+node_info["entityType"]+':'+node_info["entity"]
    data_format = node_info.get("dataFormat")
    sourceEnt="TBD"
    sourceEnt = di_client.get_data_entity(workspace_id=workspace_id,
                connection_key=node_info["connection"],schema_resource_name=node_info["schema"],data_entity_key=node_info["entityType"]+":" + node_info["entity"]).data
    entityShape=None
    if (data_format is not None) :
      # get shape
      cesd = oci.data_integration.models.CreateEntityShapeFromFile(name=node_info["entity"], resource_name=node_info["entity"], data_format=data_format)
      entityShape = di_client.create_entity_shape(workspace_id,node_info["connection"],node_info["schema"], cesd).data
      sourceEnt.data_format = data_format
      sourceEnt.shape = entityShape.shape
    dpfkey = get_uuid()
    xfld = _create_dynamic_proxy_field(node_info["entity"], dpfkey, node_info, src_entity+'/SHAPE', "projectionRules")
    output_port = OutputPort(key=keys[key+".OP1"],
                             port_type=OutputPort.PORT_TYPE_DATA,
                             name='SOURCE_OUT',
                             fields=[xfld])
    #Source Operator
    default_config = _create_config_values(node_info["dataAsset"],node_info["connection"], node_info["schema"], node_info["dataAssetType"], node_info["connectionType"], node_info.get("parameterRefs"), keys)
    src_name = "Source_" + get_time_in_millis_str()
    read_operation_config = ReadOperationConfig(key=get_uuid(), data_format=data_format)
    source_operator = Source(name=src_name,
                             output_ports=[output_port],
                             read_operation_config=read_operation_config,
                             op_config_values=default_config,
                             entity=sourceEnt)
    to_links=[]
    for linkkey in node_info["to"]:
      to_links.append(keys[linkkey])
    output_link = OutputLink(key=keys[key+".OUTPUT1"],
                             port=keys[key+".OP1"],
                             to_links=to_links)
    source_node = FlowNode(name=key, model_type='FLOW_NODE',
                           operator=source_operator,
                           output_links=[output_link],
                           ui_properties=UIProperties(coordinate_y=60, coordinate_x=160))
    return source_node

def create_filter(di_client, workspace_id, key, keys, node_info):
    #Filter Input Port
    difkey = get_uuid()
    filterfld = _create_dynamic_input_field("INPUT1", difkey)
    inputf_port = InputPort(key=keys[key+".IP1"],
                           port_type=InputPort.PORT_TYPE_DATA,
                           name='FILTER_IN',
                           fields=[filterfld])
    #Filter Output Port
    filterproxyfld =  _create_proxyfield("OUTPUT1", difkey)
    outputf_port = OutputPort(key=keys[key+".OP1"],
                             port_type=OutputPort.PORT_TYPE_DATA,
                             name='FILTER_OUT',
                             fields=[filterproxyfld])
    # Filter Operator
    filter_name = "Filter_" + get_time_in_millis_str()
    #fdefault_config = ConfigValues()
    filter_param_key = get_uuid()
    configValuesMap={"filterCondition": {"parameterValue":filter_param_key}}
    parameterRefs=node_info.get("parameterRefs")
    if (parameterRefs is not None) :
      for paramRef in parameterRefs:
        filterParam=paramRef.get("filterCondition")
        if (filterParam is not None):
          configValuesMap.update([("filterCondition", {"parameterValue": keys[filterParam]})])

    fdefault_config = ConfigValues(config_param_values=configValuesMap)
    edefault_config = ConfigValues()
    filter_operator = Filter(name=filter_name, op_config_values=fdefault_config,input_ports=[inputf_port], output_ports=[outputf_port], filter_condition=Expression(expr_string=node_info["filterCondition"], model_type="EXPRESSION", config_values=edefault_config))

    inputf_link = InputLink(key=keys[key+".INPUT1"],
                           port=keys[key+".IP1"],
                           from_link=keys[node_info["from"][0]])

    to_links=[]
    for linkkey in node_info["to"]:
      to_links.append(keys[linkkey])
    outputf_link = OutputLink(key=keys[key+".OUTPUT1"],
                             port=keys[key+".OP1"],
                             to_links=to_links)
    filter_node = FlowNode(name=key, model_type='FLOW_NODE',
                           operator=filter_operator,
                           input_links=[inputf_link],
                           output_links=[outputf_link],
                           ui_properties=UIProperties(coordinate_y=120, coordinate_x=380))
    return filter_node


def create_expression(di_client, workspace_id, key, keys, node_info, df):
    #Expression Input Port
    difkey = get_uuid()
    expressionfld = _create_dynamic_input_field("INPUT1", difkey)
    inputf_port = InputPort(key=keys[key+".IP1"],
                           port_type=InputPort.PORT_TYPE_DATA,
                           name='FILTER_IN',
                           fields=[expressionfld])
    #Expression Output Port - define expressions for output
    expressionproxyfld =  _create_proxyfield(key, difkey)
    flds=[expressionproxyfld]
    for xpr in node_info["expressions"]:
      default_config = xpr["configValues"]
      dvdfld=DerivedField(name=xpr["name"],type="Seeded:/typeSystems/PLATFORM/dataTypes/"+xpr["type"],expr=Expression(expr_string=xpr["expr"], model_type="EXPRESSION"), config_values=default_config,model_type="DERIVED_FIELD")
      flds.append(dvdfld)
    outputf_port = OutputPort(key=keys[key+".OP1"],
                             port_type=OutputPort.PORT_TYPE_DATA,
                             name='EXPRESSION_OUT',
                             fields=flds)
    # Expression Operator
    expression_name = "Expression_" + get_time_in_millis_str()
    expression_param_key = get_uuid()
    fdefault_config = ConfigValues()
    edefault_config = ConfigValues()
    #expression_operator = Projection(name=expression_name, op_config_values=fdefault_config,input_ports=[inputf_port], output_ports=[outputf_port], model_type="PROJECTION_OPERATOR", config_values=edefault_config)
    #expression_operator = Projection(name=expression_name, op_config_values=fdefault_config,input_ports=[inputf_port], output_ports=[outputf_port], model_type="PROJECTION_OPERATOR")
    expression_operator = Projection(name=expression_name, input_ports=[inputf_port], output_ports=[outputf_port], model_type="PROJECTION_OPERATOR")

    inputf_link = InputLink(key=keys[key+".INPUT1"],
                           port=keys[key+".IP1"],
                           from_link=keys[node_info["from"][0]])

    to_links=[]
    for linkkey in node_info["to"]:
      to_links.append(keys[linkkey])
    outputf_link = OutputLink(key=keys[key+".OUTPUT1"],
                             port=keys[key+".OP1"],
                             to_links=to_links)
    expression_node = FlowNode(name=key, model_type='FLOW_NODE',
                           operator=expression_operator,
                           input_links=[inputf_link],
                           output_links=[outputf_link],
                           ui_properties=UIProperties(coordinate_y=120, coordinate_x=380))
    return expression_node

def create_aggregator(di_client, workspace_id, key, keys, node_info, df):
    #Aggregator Input Port
    difkey = get_uuid()
    dpfkey = get_uuid()
    aggregatorfld = _create_dynamic_input_field("INPUT1", difkey)
    inputf_port = InputPort(key=keys[key+".IP1"],
                           port_type=InputPort.PORT_TYPE_DATA,
                           name='FILTER_IN',
                           fields=[aggregatorfld])
    #aggregator Output Port - define aggregators for output, scope if the group by dpf
    aggregatorproxyfld =  _create_proxyfield(key, dpfkey)
    flds=[aggregatorproxyfld]
    for xpr in node_info["aggregationAtts"]:
      default_config = xpr["configValues"]
      dvdfld=DerivedField(name=xpr["name"],type="Seeded:/typeSystems/PLATFORM/dataTypes/"+xpr["type"],expr=Expression(expr_string=xpr["expr"], model_type="EXPRESSION"), config_values=default_config,model_type="DERIVED_FIELD")
      flds.append(dvdfld)
    outputf_port = OutputPort(key=keys[key+".OP1"],
                             port_type=OutputPort.PORT_TYPE_DATA,
                             name='AGGREGATOR_OUT',
                             fields=flds)
    # Aggregator Operator
    aggregator_name = "Aggregator" + get_time_in_millis_str()
    aggregator_param_key = get_uuid()
    fdefault_config = ConfigValues()
    edefault_config = ConfigValues()
    grpbycolumns = _create_dynamic_proxy_field(key, dpfkey, node_info, inputf_port, "groupByAtts")
    aggregator_operator = Aggregator(name=aggregator_name, input_ports=[inputf_port], output_ports=[outputf_port], model_type="AGGREGATOR_OPERATOR", group_by_columns=grpbycolumns)
    inputf_link = InputLink(key=keys[key+".INPUT1"],
                           port=keys[key+".IP1"],
                           from_link=keys[node_info["from"][0]])

    to_links=[]
    for linkkey in node_info["to"]:
      to_links.append(keys[linkkey])
    outputf_link = OutputLink(key=keys[key+".OUTPUT1"],
                             port=keys[key+".OP1"],
                             to_links=to_links)
    aggregator_node = FlowNode(name=key, model_type='FLOW_NODE',
                           operator=aggregator_operator,
                           input_links=[inputf_link],
                           output_links=[outputf_link],
                           ui_properties=UIProperties(coordinate_y=120, coordinate_x=380))
    return aggregator_node



def create_join(di_client, workspace_id, key, keys, node_info):
    #join Input Port 1
    difkey1 = get_uuid()
    difkey2 = get_uuid()
    joinfld1 = _create_dynamic_input_field("INPUT1", difkey1)
    joinfld2 = _create_dynamic_input_field("INPUT2", difkey2)
    inputf_port = InputPort(key=keys[key+".IP1"],
                           port_type=InputPort.PORT_TYPE_DATA,
                           name='INPUT1',
                           fields=[joinfld1])
    inputj_port = InputPort(key=keys[key+".IP2"],
                           port_type=InputPort.PORT_TYPE_DATA,
                           name='INPUT2',
                           fields=[joinfld2])
    #Join Output Port
    join1proxyfld =  _create_proxyfield("OUTPUT1", difkey1)
    join2proxyfld =  _create_proxyfield("OUTPUT2", difkey2)
    outputf_port = OutputPort(key=keys[key+".OP1"],
                             port_type=OutputPort.PORT_TYPE_DATA,
                             name='JOIN_OUT',
                             fields=[join1proxyfld, join2proxyfld])
    # Join Operator
    join_name = "Join_" + get_time_in_millis_str()
    #fdefault_config = ConfigValues()
    join_param_key = get_uuid()
    parameterRefs=node_info.get("parameterRefs")
    configValuesMap={"joinCondition": {"parameterValue":join_param_key}}
    if (parameterRefs is not None) :
      for paramRef in parameterRefs:
        joinParam=paramRef.get("joinCondition")
        if (joinParam is not None):
          configValuesMap.update([("joinCondition", {"parameterValue": keys[joinParam]})])
    fdefault_config = ConfigValues(config_param_values=configValuesMap)
    edefault_config = ConfigValues()
    join_operator = Joiner(name=join_name, op_config_values=fdefault_config,input_ports=[inputf_port,inputj_port], output_ports=[outputf_port], join_condition=Expression(expr_string=node_info["joinCondition"], model_type="EXPRESSION", config_values=edefault_config))

    inputf_link = InputLink(key=keys[key+".INPUT1"],
                           port=keys[key+".IP1"],
                           from_link=keys[node_info["from"][0]])
    inputj_link = InputLink(key=keys[key+".INPUT2"],
                           port=keys[key+".IP2"],
                           from_link=keys[node_info["from"][1]])
    to_links=[]
    for linkkey in node_info["to"]:
      to_links.append(keys[linkkey])
    outputf_link = OutputLink(key=keys[key+".OUTPUT1"],
                             port=keys[key+".OP1"],
                             to_links=to_links)
    join_node = FlowNode(name=key, model_type='FLOW_NODE',
                           operator=join_operator,
                           input_links=[inputf_link, inputj_link],
                           output_links=[outputf_link],
                           ui_properties=UIProperties(coordinate_y=120, coordinate_x=380))
    return join_node

def create_target(di_client, workspace_id, key, keys, node_info, df):
    tgt_entity = node_info["connection"]+'/'+node_info["schema"]+'/'+node_info["entityType"]+':'+node_info["entity"]
    data_format = node_info.get("dataFormat")
    integration_strategy = node_info.get("integrationStrategy")
    create_new_entity = node_info.get("createNewEntity")
    targetEnt="TBD"
    if (create_new_entity is None or create_new_entity == "false") :
      targetEnt = di_client.get_data_entity(workspace_id=workspace_id,
                connection_key=node_info["connection"],schema_resource_name=node_info["schema"],data_entity_key=node_info["entityType"]+":" + node_info["entity"]).data
      targetEnt.data_format = data_format
    else:
      targetEnt = oci.data_integration.models.DataEntityFromFile(name=node_info["entity"],resource_name=node_info["entity"],data_format = data_format, entity_type="FILE",object_status=0,parent_ref=oci.data_integration.models.ParentReference(parent="987654321"))
    entityShape=None
    if (data_format is not None) :
      # get shape if its an existing entity
      if (create_new_entity is None or create_new_entity == "false") :
        cesd = oci.data_integration.models.CreateEntityShapeFromFile(name=node_info["entity"], resource_name=node_info["entity"], data_format=data_format)
        entityShape = di_client.create_entity_shape(workspace_id,node_info["connection"],node_info["schema"], cesd).data
        if (entityShape is not None) :
          targetEnt.shape = entityShape.shape
    # Target Input Port
    # Rule for mapping - here we use match by name
    name_pattern_rule = NamePatternRule(matching_strategy=NamePatternRule.MATCHING_STRATEGY_NAME_ONLY,
                                        rule_type=NamePatternRule.RULE_TYPE_INCLUDE,pattern=".*")
    rule_type_config = RuleTypeConfig(scope=tgt_entity+"/SHAPE", projection_rules=[name_pattern_rule])
    dynamic_type = DynamicType(type_handler=rule_type_config)
    tgt_field = DynamicInputField(name=key, type=dynamic_type)
    input_port = InputPort(key=keys[key+".IP1"],
                           port_type=InputPort.PORT_TYPE_DATA,
                           name='TARGET_IN',
                           fields=[tgt_field])
    # Target Operator
    write_mode=WriteOperationConfig.WRITE_MODE_APPEND
    if integration_strategy is not None:
      if integration_strategy == "OVERWRITE":
        write_mode=WriteOperationConfig.WRITE_MODE_OVERWRITE
      if integration_strategy == "MERGE":
        write_mode=WriteOperationConfig.WRITE_MODE_MERGE
    tgt_name = "Target_" + get_time_in_millis_str()
    write_operation_config = WriteOperationConfig(key=get_uuid(), model_type="WRITE_OPERATION_CONFIG", write_attribute={"modelType":"ORACLE_ADWC_WRITE_ATTRIBUTE"}, write_mode=write_mode)

    stagingBucket = node_info.get("stagingBucket")
    stagingConnection = node_info.get("stagingConnection")
    stagingDataAsset = node_info.get("stagingDataAsset")
    if stagingBucket is not None:
      write_operation_config = WriteOperationConfig(key=get_uuid(), model_type="WRITE_OPERATION_CONFIG", write_attribute={"modelType":"ORACLE_ADWC_WRITE_ATTRIBUTE", "stagingConnection":{"modelType":"ORACLE_OBJECT_STORAGE_CONNECTION", "key":stagingConnection}, "stagingDataAsset":{"modelType":"ORACLE_OBJECT_STORAGE_DATA_ASSET", "key":stagingDataAsset},"bucketSchema":{"modelType":"SCHEMA", "key":"dataref:"+stagingConnection+"/"+stagingBucket}}, write_mode=write_mode)

    tdefault_config = _create_config_values(node_info["dataAsset"],node_info["connection"], node_info["schema"], node_info["dataAssetType"], node_info["connectionType"], node_info.get("parameterRefs"), keys)
    target_operator = Target(name=tgt_name,key="987654321",
                             data_property= "APPEND",
                             input_ports=[input_port],
                             op_config_values=tdefault_config,
                             write_operation_config=write_operation_config,
                             entity=targetEnt)
    if (create_new_entity is not None) :
      if (create_new_entity == "true") :
        target_operator.is_predefined_shape = False
    # Match By Name
    name_pattern_rule_for_field_map = NamePatternRule(
        matching_strategy=NamePatternRule.MATCHING_STRATEGY_NAME_ONLY,
        rule_type=NamePatternRule.RULE_TYPE_INCLUDE,pattern=".*")
    from_rule_config = RuleTypeConfig(projection_rules=[name_pattern_rule_for_field_map])
    to_rule_config = RuleTypeConfig(projection_rules=[name_pattern_rule_for_field_map])
    field_map = RuleBasedFieldMap(from_rule_config=from_rule_config,
                                  to_rule_config=to_rule_config,
                                  map_type=RuleBasedFieldMap.MAP_TYPE_MAPBYNAME)

    createfieldmaps=[]
    # Direct Field Map (just as an example that is hard-wired)
    fieldMaps=node_info.get("fieldMaps")
    if (fieldMaps is not None):
      for fieldMap in fieldMaps:
        mapType=fieldMap.get("mapType")
        if (mapType == "MAPBYNAME"):
          name_pattern_rule_for_field_map = NamePatternRule(
          matching_strategy=NamePatternRule.MATCHING_STRATEGY_NAME_ONLY,
          rule_type=NamePatternRule.RULE_TYPE_INCLUDE,pattern=".*")
          from_rule_config = RuleTypeConfig(projection_rules=[name_pattern_rule_for_field_map])
          to_rule_config = RuleTypeConfig(projection_rules=[name_pattern_rule_for_field_map])
          field_map = RuleBasedFieldMap(from_rule_config=from_rule_config,
                                  to_rule_config=to_rule_config,
                                  map_type=RuleBasedFieldMap.MAP_TYPE_MAPBYNAME)
          createfieldmaps.append(field_map)
        else:
          source=fieldMap.get("source")
          sourceAtt=fieldMap.get("sourceAtt")
          target=fieldMap.get("target")
          targetAtt=fieldMap.get("targetAtt")
          srcConnection = df.get(source).get("connection")
          tgtConnection = df.get(target).get("connection")
          srcSchema = df.get(source).get("schema")
          tgtSchema = df.get(target).get("schema")
          srcEntity = df.get(source).get("entity")
          tgtEntity = df.get(target).get("entity")
          srcatt=srcConnection+'/'+srcSchema + '/TABLE_ENTITY:' + srcEntity + '/SHAPE/SHAPE_FIELD:' + sourceAtt
          tgtatt=srcConnection+'/'+tgtSchema + '/TABLE_ENTITY:' + tgtEntity + '/SHAPE/SHAPE_FIELD:' + targetAtt
          direct_field_map = DirectFieldMap(source_typed_object=srcatt, target_typed_object=tgtatt)
          createfieldmaps.append(direct_field_map)
    composite_field_map = CompositeFieldMap(field_maps=[field_map])
    if (len(createfieldmaps) > 0):
      composite_field_map = CompositeFieldMap(field_maps=createfieldmaps)
    input_link = InputLink(key=keys[key+".INPUT1"],
                           port=keys[key+".IP1"],
                           from_link=keys[node_info["from"][0]],
                           field_map=composite_field_map)
    target_node = FlowNode(name=key, model_type='FLOW_NODE',
                           operator=target_operator,
                           input_links=[input_link],
                           ui_properties=UIProperties(coordinate_y=120, coordinate_x=580))

    return target_node

def create_data_flow(di_client, workspace, df_name, df_identifier, folder_id, df):
  # Generate Keys
  keys={}
  for key in df:
    if (df[key]["opType"] == "SOURCE"):
      keys.update([(key+".OUTPUT1",get_uuid())])
      keys.update([(key+".OP1",get_uuid())])
    elif (df[key]["opType"] == "JOIN"):
      keys.update([(key+".INPUT1",get_uuid()), (key+".INPUT2",get_uuid()), (key+".OUTPUT1",get_uuid())])
      keys.update([(key+".IP1",get_uuid()), (key+".IP2",get_uuid()), (key+".OP1",get_uuid())])
    elif (df[key]["opType"] == "FILTER"):
      keys.update([(key+".INPUT1",get_uuid()), (key+".OUTPUT1",get_uuid())])
      keys.update([(key+".IP1",get_uuid()), (key+".OP1",get_uuid())])
    elif (df[key]["opType"] == "EXPRESSION"):
      keys.update([(key+".INPUT1",get_uuid()), (key+".OUTPUT1",get_uuid())])
      keys.update([(key+".IP1",get_uuid()), (key+".OP1",get_uuid())])
    elif (df[key]["opType"] == "AGGREGATOR"):
      keys.update([(key+".INPUT1",get_uuid()), (key+".OUTPUT1",get_uuid())])
      keys.update([(key+".IP1",get_uuid()), (key+".OP1",get_uuid())])
    elif (df[key]["opType"] == "TARGET"):
      keys.update([(key+".INPUT1",get_uuid())])
      keys.update([(key+".IP1",get_uuid())])
    elif (df[key]["opType"] == "PARAMETER"):
      keys.update([(key,get_uuid())])

  # Create Data Flow
  nodes={}
  flowNodes=[]
  parameters=[]
  for key in df:
    if (df[key]["opType"] == "PARAMETER"):
      parameters.append(create_parameter(key, keys, df[key]))
    elif (df[key]["opType"] == "SOURCE"):
      flowNodes.append(create_source(di_client, workspace, key, keys, df[key]))
    elif (df[key]["opType"] == "JOIN"):
      flowNodes.append(create_join(di_client, workspace, key, keys, df[key]))
    elif (df[key]["opType"] == "FILTER"):
      flowNodes.append(create_filter(di_client, workspace, key, keys, df[key]))
    elif (df[key]["opType"] == "EXPRESSION"):
      flowNodes.append(create_expression(di_client, workspace, key, keys, df[key], df))
    elif (df[key]["opType"] == "AGGREGATOR"):
      flowNodes.append(create_aggregator(di_client, workspace, key, keys, df[key], df))
    elif (df[key]["opType"] == "TARGET"):
      flowNodes.append(create_target(di_client, workspace, key, keys, df[key], df))

  data_flow_id = get_uuid()
  registry_metadata = RegistryMetadata(aggregator_key=folder_id)
  create_df_details= CreateDataFlowDetails(key=data_flow_id,
                                 name=df_name,
                                 identifier=df_identifier,
                                 registry_metadata=registry_metadata,
                                 nodes=flowNodes,
                                 parameters=parameters
                                 )
  create_response = di_client.create_data_flow(workspace, create_df_details)
  return create_response