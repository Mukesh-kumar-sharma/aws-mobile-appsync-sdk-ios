/// Represents a GraphQL response received from a server.
public final class GraphQLResponse<Operation: GraphQLOperation> {
  public let operation: Operation
  public let body: JSONObject

  public init(operation: Operation, body: JSONObject) {
    self.operation = operation
    self.body = body
  }

  public func parseResult(cacheKeyForObject: CacheKeyForObject? = nil) throws -> Promise<(GraphQLResult<Operation.Data>, RecordSet?)>  {
    let errors: [GraphQLError]?
    
    if let errorsEntry = body["errors"] as? [JSONObject] {
      errors = errorsEntry.map(GraphQLError.init)
    } else {
      errors = nil
    }

    if let dataEntry = body["data"] as? JSONObject {
      let executor = GraphQLExecutor { object, info in
        return .result(.success(object[info.responseKeyForField]))
      }
      
      executor.cacheKeyForObject = cacheKeyForObject
      
      let mapper = GraphQLSelectionSetMapper<Operation.Data>()
      let normalizer = GraphQLResultNormalizer()
      let dependencyTracker = GraphQLDependencyTracker()
      
      return firstly {
        try executor.execute(selections: Operation.Data.selections, on: dataEntry, withKey: Operation.rootCacheKey, variables: operation.variables, accumulator: zip(mapper, normalizer, dependencyTracker))
        }.map { (data, records, dependentKeys) in
        (GraphQLResult(data: data, errors: errors, dependentKeys: dependentKeys), records)
      }
    } else {
      return Promise(fulfilled: (GraphQLResult(data: nil, errors: errors, dependentKeys: nil), nil))
    }
  }
}

/*
func parseResultForSubscription(cacheKeyForObject: CacheKeyForObject? = nil) throws -> Promise<(GraphQLResult<Operation.Data>, RecordSet?)>  {
    let errors: [GraphQLError]?
    
    if let errorsEntry = body["errors"] as? [JSONObject] {
        errors = errorsEntry.map(GraphQLError.init)
    } else {
        errors = nil
    }
    
    if let dataEntry = body["data"] as? JSONObject {
        let executor = GraphQLExecutor { object, info in
            return .result(.success(object[info.responseKeyForField]))
        }
        
        executor.cacheKeyForObject = cacheKeyForObject
        
        let mapper = GraphQLSelectionSetMapper<Operation.Data>()
        let normalizer = GraphQLResultNormalizer()
        let dependencyTracker = GraphQLDependencyTracker()
        
        return firstly {
            try executor.execute(selections: Operation.Data.selections, on: dataEntry, withKey: Operation.rootCacheKey, variables: operation.variables, accumulator: zip(mapper, normalizer, dependencyTracker))
            }.map { (data, records, dependentKeys) in
                (GraphQLResult(data: data, errors: errors, dependentKeys: dependentKeys), records)
        }
    } else {
        return Promise(fulfilled: (GraphQLResult(data: nil, errors: errors, dependentKeys: nil), nil))
    }
}
*/

/// Represents a GraphQL response received from a server.
/*
 
public final class DataObjectResponse<Object: DataObject> {
    public let operation: String
    public let body: JSONObject
    public let object: Object
    
    public init(operation: String, body: JSONObject, object: Object) {
        self.operation = operation
        self.body = body
        self.object = object
    }
    
    func parseResult(cacheKeyForObject: CacheKeyForObject? = nil) throws -> Promise<(Object?, [GraphQLError]?, Set<CacheKey>?, RecordSet?)>  {
        let errors: [GraphQLError]?
        
        if let errorsEntry = body["errors"] as? [JSONObject] {
            errors = errorsEntry.map(GraphQLError.init)
        } else {
            errors = nil
        }
        
        if let dataEntry = body["data"] as? JSONObject {
            let executor = GraphQLExecutor { object, info in
                return .result(.success(object[info.responseKeyForField]))
            }
            
            executor.cacheKeyForObject = cacheKeyForObject
            
            let mapper = GraphQLSelectionSetMapper<Object>()
            let normalizer = GraphQLResultNormalizer()
            let dependencyTracker = GraphQLDependencyTracker()
            
            return firstly {
                var key: String?
                if (operation == "Mutation") {
                    key = "MUTATION_ROOT"
                } else {
                    key = "QUERY_ROOT"
                }
                try executor.execute(selections: Object.selections, on: dataEntry, withKey: key, variables: object.variables, accumulator: zip(mapper, normalizer, dependencyTracker))
                }.map { (data, errors, dependentKeys, records) in
                    (Object(data: data), errors, dependentKeys, records)
                }
//            }
        } else {
            return Promise(fulfilled: (nil, errors, nil, nil))
            //return Promise(fulfilled: (GraphQLResult(data: nil, errors: errors, dependentKeys: nil), nil))
        }
    }
}
*/