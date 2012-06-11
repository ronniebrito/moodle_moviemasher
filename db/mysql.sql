-- phpMyAdmin SQL Dump
-- version 3.3.2deb1
-- http://www.phpmyadmin.net
--
-- Servidor: localhost
-- Tempo de Geração: Jul 18, 2011 as 05:53 PM
-- Versão do Servidor: 5.1.41
-- Versão do PHP: 5.3.2-1ubuntu4.9

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Banco de Dados: `moodleetica`
--

-- --------------------------------------------------------

--
-- Estrutura da tabela `mdl_moviemasher`
--

CREATE TABLE IF NOT EXISTS `{$CFG->prefix}moviemasher` (
  `id` bigint(10) unsigned NOT NULL AUTO_INCREMENT,
  `course` bigint(10) unsigned NOT NULL DEFAULT '0',
  `name` varchar(255) NOT NULL DEFAULT '',
  `intro` mediumtext,
  `moviemashervideo` varchar(255) DEFAULT NULL,
  `default_mash` mediumtext,
  `introformat` smallint(4) unsigned NOT NULL DEFAULT '0',
  `timecreated` bigint(10) unsigned NOT NULL DEFAULT '0',
  `timemodified` bigint(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `mdl_movi_cou_ix` (`course`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='Default comment for moviemasher, please edit me' AUTO_INCREMENT=2 ;

-- --------------------------------------------------------

--
-- Estrutura da tabela `mdl_moviemasher_mash`
--

CREATE TABLE IF NOT EXISTS `{$CFG->prefix}moviemasher_mash` (
  `id` bigint(10) unsigned NOT NULL AUTO_INCREMENT,
  `moviemasher_id` bigint(10) unsigned NOT NULL DEFAULT '0',
  `user_id` bigint(10) unsigned NOT NULL DEFAULT '0',
  `mash` mediumtext,
  `text` text,
  `timecreated` bigint(10) unsigned NOT NULL DEFAULT '0',
  `timemodified` bigint(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='answer masher of the activity' AUTO_INCREMENT=2 ;

-- --------------------------------------------------------

--
-- Estrutura da tabela `mdl_moviemasher_video`
--

CREATE TABLE IF NOT EXISTS `{$CFG->prefix}moviemasher_video` (
  `id` bigint(10) unsigned NOT NULL AUTO_INCREMENT,
  `mash_id` bigint(10) unsigned NOT NULL DEFAULT '0',
  `name` mediumtext,
  `duration` mediumtext,
  `timecreated` bigint(10) unsigned NOT NULL DEFAULT '0',
  `timemodified` bigint(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='videos belonging to a certain user mash' AUTO_INCREMENT=85 ;
