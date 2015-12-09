require("livescript");
require("colors");
app = require("./app.ls");
var program = require('commander');

function rank(v){
  v = Number(v);
  if(v >=0 && v<= 10){
    return v;
  }else {
    return 0;
  }
};

function classification(v){
  return v.split(" ");
};

program
  .version('0.0.1')

program
  .command('update')
  .description('更新电影数据库')
  .action(function(){
    app.execGrap(function(){
      console.log("更新完成");
    });
  });

program
  .command('random')
  .description('随机一个电影')
  .option('-r, --rank <int>', '筛选评分', rank)
  .option('-c, --classification <ary>', '筛选分类', classification)
  .action(function(options){
    rank = options.rank || 0;
    classification = options.classification || [];
    app.execSmartRandomMovie({
      rank: rank,
      ciAry: classification
    })
  });

program
  .command('clean')
  .description('删除缓存')
  .action(function(options){
    app.execClean();
  });

program.parse(process.argv);
